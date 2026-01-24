import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_state.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';

import 'package:walleta/screens/sharedExpenses/add_expense.dart';
import 'package:walleta/widgets/cards/expense_card.dart';

class SharedExpensesScreen extends StatefulWidget {
  const SharedExpensesScreen({Key? key}) : super(key: key);

  @override
  State<SharedExpensesScreen> createState() => _SharedExpensesScreenState();
}

class _SharedExpensesScreenState extends State<SharedExpensesScreen> {
  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    final userId = context.read<AuthenticationBloc>().state.user.uid;
    context.read<SharedExpenseBloc>().add(LoadSharedExpenses(userId: userId));
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddExpenseSheet(
            onSave: (expense) {
              // Recargar los gastos después de agregar uno nuevo
              _loadExpenses();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color iconsColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : const Color(0xFFF8FAFD);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            // Escuchar cuando se agrega un pago exitosamente
            BlocListener<ExpensePaymentBloc, ExpensePaymentState>(
              listener: (context, state) {
                if (ExpensePaymentStatus.success == state.status) {
                  // Recargar los gastos cuando se agrega un pago
                  _loadExpenses();
                }
              },
            ),
          ],
          child: BlocBuilder<SharedExpenseBloc, SharedExpenseState>(
            builder: (context, state) {
              if (state.status == SharedExpenseStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == SharedExpenseStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error al cargar los gastos'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadExpenses,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // AppBar
                  SliverAppBar(
                    floating: true,
                    backgroundColor: backgroundColor,
                    elevation: 0,
                    title: Text(
                      'Gastos Compartidos',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(Iconsax.add, color: iconsColor),
                        onPressed: () {
                          _showAddExpenseSheet();
                        },
                      ),
                      IconButton(
                        icon: Icon(Iconsax.filter, color: iconsColor),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  if (state.expenses.isEmpty)
                    SliverToBoxAdapter(child: _buildEmptyState())
                  else
                    // Padding general para todas las cards
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            // Padding entre cada card
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ExpenseCard(expense: state.expenses[index]),
                          );
                        }, childCount: state.expenses.length),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2D5BFF), const Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5BFF).withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Iconsax.receipt_2, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay gastos compartidos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Comienza a dividir gastos con amigos, familia o compañeros',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Sugerencias
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5BFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Iconsax.lamp_charge,
                          size: 18,
                          color: Color(0xFF2D5BFF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Comienza con:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestionItem(
                    icon: Icons.restaurant,
                    text: 'Cena en restaurante',
                    color: const Color(0xFF00C896),
                  ),
                  _buildSuggestionItem(
                    icon: Iconsax.car,
                    text: 'Viaje en coche',
                    color: const Color(0xFF2D5BFF),
                  ),
                  _buildSuggestionItem(
                    icon: Iconsax.home,
                    text: 'Gastos del hogar',
                    color: const Color(0xFFFFA726),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            size: 16,
            color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}
