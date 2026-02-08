// shared_expense_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/shared_expense_payment.dart';
import 'package:walleta/screens/sharedExpenses/shared_expense_history.dart';
import 'package:walleta/widgets/payment/register_payment_dialog.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:walleta/utils/formatters.dart';
import 'package:walleta/widgets/common/draggable_to_delete_card.dart';

class SharedExpenseCard extends StatefulWidget {
  final SharedExpense expense;
  final Function(bool)? onDragStateChanged;

  const SharedExpenseCard({
    super.key,
    required this.expense,
    this.onDragStateChanged,
  });

  @override
  State<SharedExpenseCard> createState() => _SharedExpenseCardState();
}

class _SharedExpenseCardState extends State<SharedExpenseCard> {
  bool _showParticipants = false;
  final _participantsKey = GlobalKey();

  void _toggleParticipantsOverlay(BuildContext context) {
    final RenderBox renderBox =
        _participantsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _showParticipants = !_showParticipants;
    });

    if (_showParticipants) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _showParticipants = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        top: position.dy,
                        right:
                            MediaQuery.of(context).size.width -
                            position.dx -
                            renderBox.size.width,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: _buildParticipantsOverlay(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      });
    }
  }

  Widget _buildParticipantsOverlay(BuildContext context) {
    final participantsCount = widget.expense.participants.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double calculateHeight() {
      if (participantsCount == 0) return 100;
      double baseHeight = 80;
      const participantHeight = 40.0;
      double contentHeight =
          baseHeight + (participantsCount * participantHeight);
      final maxScreenHeight = MediaQuery.of(context).size.height * 0.7;
      if (contentHeight > maxScreenHeight) return maxScreenHeight;
      return contentHeight;
    }

    final containerHeight = calculateHeight();
    final needsScroll = participantsCount > 2;

    return Container(
      width: 150,
      height: containerHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.people, size: 16, color: const Color(0xFF2D5BFF)),
                const SizedBox(width: 8),
                Text(
                  'Participantes ($participantsCount)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          if (needsScroll)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: _buildParticipantsList(isDark),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: _buildParticipantsList(isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          widget.expense.participants.map((participant) {
            return Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.expense.categoryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        participant.username.isNotEmpty
                            ? participant.username[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.expense.categoryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      participant.username,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: DraggableToDeleteCard(
        isDark: isDark,
        onDeleteConfirmed: () => _handleDelete(context),
        onCardTap: () => _showExpenseDetails(context),
        onDragStateChanged: widget.onDragStateChanged,
        deleteDialogTitle: '¿Eliminar gasto compartido?',
        deleteDialogMessage:
            'Esta acción no se puede deshacer. '
            'Se eliminará el gasto "${widget.expense.title}" y todos sus pagos asociados.',
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.expense.paid / widget.expense.total;
    final isComplete = progress >= 1.0;
    final remaining = widget.expense.total - widget.expense.paid;
    final remainingBalance = widget.expense.total - widget.expense.paid;
    final participantsCount = widget.expense.participants.length;

    Color getProgressColor(double progress) {
      if (progress <= 0.25) return const Color(0xFFFF6B6B);
      if (progress <= 0.50) return const Color(0xFFFFA726);
      if (progress <= 0.75) return const Color(0xFF2D5BFF);
      if (progress < 1.0) return const Color(0xFF00C896);
      return const Color(0xFF10B981);
    }

    final progressColor = getProgressColor(progress);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
            child: Stack(
              children: [
                Column(
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
                                  color: widget.expense.categoryColor
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.expense.categoryIcon,
                                    color: widget.expense.categoryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // CATEGORÍA
                                    Text(
                                      widget.expense.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.expense.categoryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.expense.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                              Formatters.formatCurrencyNoDecimals(
                                widget.expense.paid,
                              ),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color:
                                    progressColor, // Color dinámico según progreso
                              ),
                            ),
                            Text(
                              'Pagado',
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
                              Formatters.formatCurrencyNoDecimals(
                                widget.expense.total,
                              ),
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
                              'Total',
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
                      tween: Tween<double>(
                        begin: 0,
                        end: progress.clamp(0.0, 1.0),
                      ),
                      builder: (context, value, _) {
                        return Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color:
                                isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFF3F4F6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
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
                                      colors:
                                          isComplete
                                              ? const [
                                                Color(0xFF00C896),
                                                Color(0xFF10B981),
                                              ]
                                              : [
                                                progressColor,
                                                Color.lerp(
                                                  progressColor,
                                                  Colors.white,
                                                  0.2,
                                                )!,
                                              ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: progressColor.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.2),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.3],
                                          ),
                                        ),
                                      ),
                                    ],
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
                          if (!isComplete)
                            Container(
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: progressColor.withOpacity(0.3),
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
                                    Iconsax.money_send,
                                    size: 10,
                                    color: progressColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Faltante: ${Formatters.formatCurrencyNoDecimals(remaining)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: progressColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (!isComplete && remainingBalance > 0)
                            GestureDetector(
                              onTap: () => _showRegisterPaymentDialog(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.3),
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
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Registrar Pago',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).primaryColor,
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

                // BOTÓN DE PARTICIPANTES - MANTENIDO DEL DISEÑO ORIGINAL
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    key: _participantsKey,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5BFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2D5BFF).withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _toggleParticipantsOverlay(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.people,
                                size: 14,
                                color: const Color(0xFF2D5BFF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                participantsCount == 1
                                    ? '1'
                                    : participantsCount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF2D5BFF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_showParticipants)
                                Icon(
                                  Iconsax.arrow_up_2,
                                  size: 10,
                                  color: const Color(0xFF2D5BFF),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
      context.read<SharedExpenseBloc>().add(
        DeleteSharedExpense(
          widget.expense,
          context.read<AuthenticationBloc>().state.user,
        ),
      );

      TopSnackBarOverlay.show(
        context: context,
        message: 'Gasto compartido eliminado exitosamente',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFF00C896),
      );
    } catch (e) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Error al eliminar el gasto compartido: $e',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
    }
  }

  void _showExpenseDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          color: Colors.black.withOpacity(0.5),
          child: DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white30 : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.expense.categoryColor.withOpacity(
                                0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                widget.expense.categoryIcon,
                                color: widget.expense.categoryColor,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.expense.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.expense.participants.length} participantes • ${Formatters.formatCurrencyNoDecimals(widget.expense.total)} total',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ExpensePaymentHistory(
                            expense: widget.expense,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRegisterPaymentDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingBalance = widget.expense.total - widget.expense.paid;

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
          subtitle: widget.expense.title,
          totalAmount: widget.expense.total,
          paidAmount: widget.expense.paid,
          isDark: isDark,
          onPaymentConfirmed: (amount, note, image) async {
            final currentUser = context.read<AuthenticationBloc>().state.user;

            final payment = SharedExpensePayment(
              userId: currentUser.uid,
              expenseId: widget.expense.id!,
              payerName: '${currentUser.name} ${currentUser.surname}',
              amount: amount,
              date: DateTime.now(),
              description: note,
              receiptImageUrl: image?.path,
            );

            final newPaidAmount = widget.expense.paid + amount;

            try {
              context.read<ExpensePaymentBloc>().add(
                AddExpensePayment(
                  payment: payment,
                  newPaidAmount: newPaidAmount,
                ),
              );

              final updatedExpense = SharedExpense(
                id: widget.expense.id,
                title: widget.expense.title,
                total: widget.expense.total,
                paid: newPaidAmount,
                participants: widget.expense.participants,
                category: widget.expense.category,
                categoryIcon: widget.expense.categoryIcon,
                categoryColor: widget.expense.categoryColor,
                status:
                    newPaidAmount >= widget.expense.total
                        ? 'completado'
                        : 'pendiente',
                createdAt: widget.expense.createdAt,
                createdBy: currentUser,
              );

              context.read<SharedExpenseBloc>().add(
                UpdateSharedExpense(expense: updatedExpense),
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
