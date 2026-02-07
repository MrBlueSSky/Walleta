// personal_expenses_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_event.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_state.dart';
import 'package:walleta/blocs/personalExpensePayment/bloc/personal_expense_payment_bloc.dart';
import 'package:walleta/models/personal_expense.dart';
import 'package:walleta/models/personal_expense_payment.dart';
import 'package:walleta/screens/loans/filter_option.dart';
import 'package:walleta/screens/profile/personalExpense/personal_expense.dart';
import 'package:walleta/utils/formatters.dart';
import 'package:walleta/widgets/payment/register_payment_dialog.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:walleta/widgets/common/draggable_to_delete_card.dart'; // NUEVO
import 'package:walleta/widgets/common/trash_overlay.dart'; // NUEVO

class PersonalExpensesListScreen extends StatefulWidget {
  final String userId;

  const PersonalExpensesListScreen({super.key, required this.userId});

  @override
  State<PersonalExpensesListScreen> createState() =>
      _PersonalExpensesListScreenState();
}

class _PersonalExpensesListScreenState
    extends State<PersonalExpensesListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilter = 0; // 0: Todos, 1: Pagados, 2: Pendientes
  final TrashOverlayController _trashController =
      TrashOverlayController(); // NUEVO

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PersonalExpenseBloc>().add(
        LoadPersonalExpenses(widget.userId),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _trashController.hideOverlay(); // CAMBIADO
    super.dispose();
  }

  Future<void> _refreshExpenses() async {
    context.read<PersonalExpenseBloc>().add(
      LoadPersonalExpenses(widget.userId),
    );
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PersonalExpenseSheet(userId: widget.userId),
    ).then((_) {
      context.read<PersonalExpenseBloc>().add(
        LoadPersonalExpenses(widget.userId),
      );
    });
  }

  List<PersonalExpense> _filterExpenses(List<PersonalExpense> expenses) {
    switch (_selectedFilter) {
      case 1: // Pagados
        return expenses.where((e) => e.paid >= e.total).toList();
      case 2: // Pendientes
        return expenses.where((e) => e.paid >= 0 && e.paid < e.total).toList();
      default: // Todos
        return expenses;
    }
  }

  void _showFilterDialog(bool isDark) {
    bool allSelected = true;
    bool pendingSelected = false;
    bool partialSelected = false;
    bool overdueSelected = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Filtrar',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterOption(
                      option: 'Todos',
                      isSelected: allSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          allSelected = !allSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Pendientes',
                      isSelected: pendingSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          pendingSelected = !pendingSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Parciales',
                      isSelected: partialSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          partialSelected = !partialSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Atrasados',
                      isSelected: overdueSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          overdueSelected = !overdueSelected;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Aplicar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _updateDragState(bool isDragging) {
    // SIMPLIFICADO
    if (isDragging) {
      _trashController.showOverlay(context);
    } else {
      _trashController.hideOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);

    Color iconsColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<PersonalExpenseBloc, PersonalExpenseState>(
        builder: (context, state) {
          final expenses = state.expenses;
          final filteredExpenses = _filterExpenses(expenses);

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Gastos Personales',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Iconsax.add, color: iconsColor, size: 24),
                      onPressed: () {
                        _showAddExpenseSheet();
                      },
                    ),
                    IconButton(
                      icon: Icon(Iconsax.filter, color: iconsColor, size: 24),
                      onPressed: () => _showFilterDialog(isDark),
                    ),
                  ],
                ),
                SliverToBoxAdapter(child: _buildFilterTabs(isDark)),
              ];
            },
            body: _buildContent(isDark, state, filteredExpenses),
          );
        },
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    const filters = ['Todos', 'Pagados', 'Pendientes'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB).withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: Row(
        children:
            filters.asMap().entries.map((entry) {
              final index = entry.key;
              final filter = entry.value;
              return Expanded(
                child: _buildFilterTab(
                  label: filter,
                  isSelected: _selectedFilter == index,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedFilter = index),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2D5BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    bool isDark,
    PersonalExpenseState state,
    List<PersonalExpense> filteredExpenses,
  ) {
    if (state.status == PersonalExpenseStateStatus.loading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? Colors.white : const Color(0xFF2D5BFF),
        ),
      );
    }

    if (state.status == PersonalExpenseStateStatus.error) {
      return RefreshIndicator(
        onRefresh: _refreshExpenses,
        color: isDark ? Colors.white : const Color(0xFF2D5BFF),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.warning_2,
                    size: 48,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar gastos',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Error desconocido',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => context.read<PersonalExpenseBloc>().add(
                          LoadPersonalExpenses(widget.userId),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (filteredExpenses.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshExpenses,
        color: isDark ? Colors.white : const Color(0xFF2D5BFF),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.receipt,
                    size: 64,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 0
                        ? 'No hay gastos registrados'
                        : 'No hay gastos en esta categoría',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 0
                        ? 'Agrega tu primer gasto personal'
                        : 'Intenta cambiar el filtro',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  if (_selectedFilter == 0) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showAddExpenseSheet,
                      icon: const Icon(Iconsax.add, size: 18),
                      label: const Text('Agregar gasto'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5BFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshExpenses,
      color: isDark ? Colors.white : const Color(0xFF2D5BFF),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ExpenseCard(
              expense: expense,
              isDark: isDark,
              userId: widget.userId,
              key: ValueKey(expense.id),
              onDragStateChanged: _updateDragState,
            ),
          );
        },
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  final PersonalExpense expense;
  final bool isDark;
  final String userId;
  final Function(bool) onDragStateChanged;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.isDark,
    required this.userId,
    required this.onDragStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableToDeleteCard(
      isDark: isDark,
      onDeleteConfirmed: () => _handleDelete(context),
      onCardTap: () => _showExpenseDetails(context),
      onDragStateChanged: onDragStateChanged,
      deleteDialogTitle: '¿Eliminar gasto?',
      deleteDialogMessage:
          'Esta acción no se puede deshacer. '
          'Se eliminará el gasto "${expense.title}" y todos sus pagos asociados.',
      child: _buildCardContent(context),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final remaining = expense.total - expense.paid;
    final progress = expense.total > 0 ? expense.paid / expense.total : 0;
    final statusText = _getStatusText(expense.paid, expense.total);
    final statusColor = _getStatusColor(expense.paid, expense.total);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB).withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showExpenseDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: expense.categoryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                expense.categoryIcon ?? Iconsax.category,
                                size: 20,
                                color: expense.categoryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.title.isNotEmpty
                                      ? expense.title
                                      : 'Gasto sin título',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  expense.category.isNotEmpty
                                      ? expense.category
                                      : 'Sin categoría',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.formatCurrencyNoDecimals(expense.total),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Monto total',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(expense.createdAt),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Fecha',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutQuart,
                  tween: Tween<double>(begin: 0.0, end: progress as double),
                  builder: (context, value, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF3F4F6),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF3F4F6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    statusColor,
                                    Color.lerp(statusColor, Colors.white, 0.2)!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.wallet_money,
                              size: 10,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pendiente: ${Formatters.formatCurrencyNoDecimals(remaining)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _showRegisterPaymentDialog(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D5BFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF2D5BFF).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.add_circle,
                                size: 10,
                                color: const Color(0xFF2D5BFF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Registrar Pago',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D5BFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    try {
      context.read<PersonalExpenseBloc>().add(
        DeletePersonalExpense(expense.id!),
      );

      TopSnackBarOverlay.show(
        context: context,
        message: 'Gasto eliminado exitosamente',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFF00C896),
      );
    } catch (e) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Error al eliminar el gasto',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
    }
  }

  String _getStatusText(double paid, double total) {
    if (paid >= total) return 'Pagado';
    return 'Pendiente';
  }

  Color _getStatusColor(double paid, double total) {
    if (paid >= total) return const Color(0xFF10B981);
    if (paid > 0) return const Color(0xFF2D5BFF);
    return const Color(0xFFF59E0B);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showExpenseDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildExpenseDetailsContent(scrollController),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseDetailsContent(ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            expense.title.isNotEmpty ? expense.title : 'Gasto sin título',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                expense.categoryIcon ?? Iconsax.category,
                size: 16,
                color: expense.categoryColor,
              ),
              const SizedBox(width: 8),
              Text(
                expense.category.isNotEmpty
                    ? expense.category
                    : 'Sin categoría',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Total del gasto',
                    Formatters.formatCurrencyNoDecimals(expense.total),
                  ),
                  _buildDetailRow(
                    'Pagado',
                    Formatters.formatCurrencyNoDecimals(expense.paid),
                    color: const Color(0xFF10B981),
                  ),
                  _buildDetailRow(
                    'Pendiente',
                    Formatters.formatCurrencyNoDecimals(
                      expense.total - expense.paid,
                    ),
                    color: const Color(0xFFF59E0B),
                  ),
                  _buildDetailRow('Fecha', _formatDate(expense.createdAt)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color ?? (isDark ? Colors.white : const Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterPaymentDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingBalance = expense.total - expense.paid;

    if (remainingBalance <= 0) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Este gasto ya está completamente pagado',
        verticalOffset: 70.0,
        backgroundColor: Colors.orange,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RegisterPaymentDialog(
          title: 'Registrar Pago',
          subtitle: expense.title,
          totalAmount: expense.total,
          paidAmount: expense.paid,
          isDark: isDark,
          onPaymentConfirmed: (amount, note, image) async {
            final currentUser = context.read<AuthenticationBloc>().state.user;

            final payment = PersonalExpensePayment(
              userId: currentUser.uid,
              expenseId: expense.id!,
              payerName: '${currentUser.name} ${currentUser.surname}',
              amount: amount,
              date: DateTime.now(),
              description: note,
              receiptImageUrl: image?.path,
            );

            final newPaidAmount = expense.paid + amount;

            try {
              context.read<PersonalExpensePaymentBloc>().add(
                AddPersonalExpensePayment(
                  payment: payment,
                  newPaidAmount: newPaidAmount,
                ),
              );

              final updatedPersonalExpense = PersonalExpense(
                id: expense.id,
                title: expense.title,
                total: expense.total,
                paid: newPaidAmount,
                category: expense.category,
                categoryIcon: expense.categoryIcon,
                categoryColor: expense.categoryColor,
                status:
                    newPaidAmount >= expense.total ? 'completado' : 'pendiente',
                createdAt: expense.createdAt,
              );

              context.read<PersonalExpenseBloc>().add(
                UpdatePersonalExpense(expense: updatedPersonalExpense),
              );

              TopSnackBarOverlay.show(
                context: context,
                message:
                    'Pago de ${Formatters.formatCurrencyNoDecimals(amount)} registrado exitosamente',
                verticalOffset: 70.0,
                backgroundColor: const Color(0xFF00C896),
              );
            } catch (e) {
              TopSnackBarOverlay.show(
                context: context,
                message: 'Error: $e',
                verticalOffset: 70.0,
                backgroundColor: const Color(0xFFFF6B6B),
              );
              rethrow;
            }
          },
        );
      },
    );
  }
}
