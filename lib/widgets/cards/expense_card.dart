import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/shared_expense_payment.dart';
import 'package:walleta/screens/sharedExpenses/shared_expense_history.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/payment/register_payment_dialog.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';

class ExpenseCard extends StatefulWidget {
  final SharedExpense expense;
  const ExpenseCard({super.key, required this.expense});

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _showParticipants = false;
  final _participantsKey = GlobalKey();

  void _showExpenseDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.expense.paid / widget.expense.total;

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
                    // Handle
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

                    // Header
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
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.expense.participants.length} participantes • ₡${widget.expense.total.toInt()} total',
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

                    // Progreso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pagado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.white60
                                            : const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₡${widget.expense.paid.toInt()}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: widget.expense.categoryColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Progreso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? Colors.white60
                                            : const Color(0xFF9CA3AF),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Historial de pagos
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Solo mostrar el diálogo si hay saldo pendiente
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
            // Obtener el nombre del usuario actual
            final currentUser =
                context.read<AuthenticationBloc>().state.user?.name ??
                'Desconocido';

            // Crear el pago
            final payment = SharedExpensePayment(
              expenseId: widget.expense.id!,
              payerName: currentUser,
              amount: amount,
              date: DateTime.now(),
              description: note,
              receiptImageUrl: image?.path,
            );

            // Calcular nuevo monto pagado
            final newPaidAmount = widget.expense.paid + amount;

            try {
              // 1. Agregar el pago al BLoC
              context.read<ExpensePaymentBloc>().add(
                AddExpensePayment(
                  payment: payment,
                  newPaidAmount: newPaidAmount,
                ),
              );

              // 2. Actualizar el gasto compartido
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
              );

              // 3. Actualizar en el BLoC de gastos compartidos
              context.read<SharedExpenseBloc>().add(
                UpdateSharedExpense(expense: updatedExpense),
              );

              // 4. Mostrar confirmación
              TopSnackBarOverlay.show(
                context: context,
                message: 'Pago de ₡${amount.toInt()} registrado exitosamente',
                verticalOffset: 70.0,
                backgroundColor: const Color(0xFF00C896),
              );
            } catch (e) {
              TopSnackBarOverlay.show(
                context: context,
                message: 'Error: $e',
                verticalOffset:
                    70.0, // Ajusta este número: 50, 60, 70, 80, etc.
                backgroundColor: const Color(0xFFFF6B6B),
              );
              rethrow;
            }
          },
        );
      },
    );
  }

  void _toggleParticipantsOverlay(BuildContext context) {
    final RenderBox renderBox =
        _participantsKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    setState(() {
      _showParticipants = !_showParticipants;
    });

    // Si estamos mostrando el overlay, podemos configurar un listener para cerrarlo al tocar fuera
    if (_showParticipants) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Cerrar al tocar fuera
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
                      // Overlay flotante de participantes
                      Positioned(
                        top: position.dy + renderBox.size.height + 8,
                        right:
                            MediaQuery.of(context).size.width -
                            position.dx -
                            renderBox.size.width,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 250,
                            constraints: BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
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
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE5E7EB),
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header del overlay
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFFF3F4F6),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.people,
                                        size: 16,
                                        color: const Color(0xFF2D5BFF),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Participantes (${widget.expense.participants.length})',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Lista de participantes
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(12),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          widget.expense.participants.map((
                                            participant,
                                          ) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                          0xFF0F172A,
                                                        )
                                                        : const Color(
                                                          0xFFF9FAFB,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? const Color(
                                                            0xFF334155,
                                                          )
                                                          : const Color(
                                                            0xFFE5E7EB,
                                                          ),
                                                  width: 0.5,
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: widget
                                                          .expense
                                                          .categoryColor
                                                          .withOpacity(0.2),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        participant
                                                            .substring(0, 1)
                                                            .toUpperCase(),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              widget
                                                                  .expense
                                                                  .categoryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    participant,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white70
                                                              : const Color(
                                                                0xFF6B7280,
                                                              ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.expense.paid / widget.expense.total;
    final isComplete = progress >= 1.0;
    final remaining = widget.expense.total - widget.expense.paid;
    final participantsCount = widget.expense.participants.length;

    // Color basado en el progreso
    Color getProgressColor(double progress) {
      if (progress <= 0.25) return const Color(0xFFFF6B6B);
      if (progress <= 0.50) return const Color(0xFFFFA726);
      if (progress <= 0.75) return const Color(0xFF2D5BFF);
      if (progress < 1.0) return const Color(0xFF00C896);
      return const Color(0xFF10B981);
    }

    final progressColor = getProgressColor(progress);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final remainingBalance = widget.expense.total - widget.expense.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: widget.expense.categoryColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                widget.expense.categoryIcon,
                                color: widget.expense.categoryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Barra de progreso
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: progress.clamp(0.0, 1.0),
                      ),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Column(
                          children: [
                            // Labels de monto
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0,
                                    end: widget.expense.paid,
                                  ),
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, paidValue, _) {
                                    return Text(
                                      '₡${paidValue.toInt()}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: progressColor,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  '₡${widget.expense.total.toInt()}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark
                                            ? Colors.white70
                                            : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Barra de progreso
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutCubic,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.7 *
                                        value,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors:
                                            isComplete
                                                ? const [
                                                  Color(0xFF00C896),
                                                  Color(0xFF10B981),
                                                ]
                                                : [
                                                  progressColor,
                                                  progressColor.withOpacity(
                                                    0.8,
                                                  ),
                                                ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Información de progreso
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // FALTANTE - AL INICIO (IZQUIERDA)
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
                                            'Faltante: ₡${remaining.toInt()}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: progressColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // REGISTRAR PAGO - AL FINAL (DERECHA)
                                  if (!isComplete && remainingBalance > 0)
                                    GestureDetector(
                                      onTap:
                                          () => _showRegisterPaymentDialog(
                                            context,
                                          ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Registrar Pago',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
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
                        );
                      },
                    ),
                  ],
                ),

                // Botón de participantes en la esquina superior derecha
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
}
