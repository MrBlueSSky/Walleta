import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/shared_expense_payment.dart';
import 'package:walleta/screens/loans/details/receipt_image_dialog%20.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:walleta/utils/formatters.dart'; // ← AGREGAR ESTA LÍNEA

class ExpensePaymentHistory extends StatefulWidget {
  final SharedExpense expense;
  final bool isDark;

  const ExpensePaymentHistory({
    super.key,
    required this.expense,
    required this.isDark,
  });

  @override
  State<ExpensePaymentHistory> createState() => _ExpensePaymentHistoryState();
}

class _ExpensePaymentHistoryState extends State<ExpensePaymentHistory> {
  bool _paymentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    if (!_paymentsLoaded && widget.expense.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ahora usa el BLoC que ya está disponible globalmente
        context.read<ExpensePaymentBloc>().add(
          LoadExpensePayments(widget.expense.id!),
        );
        _paymentsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensePaymentBloc, ExpensePaymentState>(
      builder: (context, state) {
        if (state.status == ExpensePaymentStatus.initial && !_paymentsLoaded) {
          _loadPayments();
        }

        final paymentCount = state.payments.length;
        final totalPaid = state.payments.fold<double>(
          0,
          (sum, payment) => sum + payment.amount,
        );

        Widget content;

        if (state.status == ExpensePaymentStatus.loading) {
          content = const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.status == ExpensePaymentStatus.error) {
          content = _buildErrorWidget(state.errorMessage);
        } else if (state.payments.isEmpty) {
          content = _buildEmptyWidget();
        } else {
          content = _buildPaymentsList(state.payments, totalPaid);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de Pagos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        widget.isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '$paymentCount pago${paymentCount != 1 ? 's' : ''}', // ← CAMBIADO
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        widget.isDark
                            ? Colors.white70
                            : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget(String? errorMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color:
            widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Error al cargar pagos',
              style: TextStyle(
                color: widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color:
              widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 48,
              color: widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(
              'No hay pagos registrados',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Realiza el primer pago para verlo aquí',
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList(
    List<SharedExpensePayment> payments,
    double totalPaid,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Resumen rápido
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total pagado',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDark
                                ? Colors.white60
                                : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(totalPaid), // ← CAMBIADO
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Restante',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDark
                                ? Colors.white60
                                : const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatCurrency(
                        widget.expense.total - totalPaid,
                      ), // ← CAMBIADO
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.expense.categoryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de pagos
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: payments.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  thickness: 0.5,
                  color:
                      widget.isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE5E7EB),
                  indent: 16,
                  endIndent: 16,
                ),
            itemBuilder: (context, index) {
              final payment = payments[index];
              return _ExpensePaymentItem(
                payment: payment,
                isDark: widget.isDark,
                expenseColor: widget.expense.categoryColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExpensePaymentItem extends StatelessWidget {
  final SharedExpensePayment payment;
  final bool isDark;
  final Color expenseColor;

  const _ExpensePaymentItem({
    required this.payment,
    required this.isDark,
    required this.expenseColor,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  void _showReceiptImage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (payment.receiptImageUrl == null || payment.receiptImageUrl!.isEmpty) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'No hay comprobante disponible',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => ReceiptImageDialog(
            imageUrl: payment.receiptImageUrl!,
            payment: payment,
            isDark: isDark,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          payment.receiptImageUrl != null && payment.receiptImageUrl!.isNotEmpty
              ? () => _showReceiptImage(context)
              : null,
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del pagador
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: expenseColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    payment.payerName.isNotEmpty
                        ? payment.payerName.substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: expenseColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Información del pago
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment.payerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            payment.amount,
                          ), // ← CAMBIADO
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: expenseColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color:
                              isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(payment.date),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color:
                              isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(payment.date),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                        // Indicador de imagen
                        if (payment.receiptImageUrl != null &&
                            payment.receiptImageUrl!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.image, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Comprobante',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (payment.description != null &&
                        payment.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF6B7280),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (payment.paymentMethod != null &&
                        payment.paymentMethod!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: expenseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.paymentMethod!,
                          style: TextStyle(
                            fontSize: 10,
                            color: expenseColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Indicador de que es tappable
              if (payment.receiptImageUrl != null &&
                  payment.receiptImageUrl!.isNotEmpty)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
