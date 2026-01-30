import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/shared_expense_payment.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:walleta/utils/formatters.dart';

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
            // Sección de resumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.isDark
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
                        Formatters.formatCurrencyNoDecimals(totalPaid),
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
                        Formatters.formatCurrencyNoDecimals(
                          widget.expense.total - totalPaid,
                        ),
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
            const SizedBox(height: 16),

            // Título del historial
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
                  '$paymentCount pago${paymentCount != 1 ? 's' : ''}',
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

            // Contenido (lista de pagos)
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
    return Container(
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
    );
  }

  Widget _buildPaymentsList(
    List<SharedExpensePayment> payments,
    double totalPaid,
  ) {
    final hasMoreThanSixPayments = payments.length > 6;
    final displayPayments = payments.take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color:
            widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Lista de pagos (con scroll si hay más de 6)
          if (hasMoreThanSixPayments)
            // Versión con scroll y altura fija
            Container(
              height: 320, // Altura fija para el área scrollable
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ...payments.map((payment) => _buildPaymentItem(payment)),
                  ],
                ),
              ),
            )
          else
            // Versión sin scroll (altura dinámica)
            Column(
              children: [
                ...displayPayments.map((payment) => _buildPaymentItem(payment)),
              ],
            ),

          // // Mostrar contador si hay más de 6 pagos
          // if (hasMoreThanSixPayments)
          //   Padding(
          //     padding: const EdgeInsets.all(12),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(
          //           Icons.info_outline,
          //           size: 14,
          //           color:
          //               widget.isDark
          //                   ? Colors.white60
          //                   : const Color(0xFF9CA3AF),
          //         ),
          //         const SizedBox(width: 6),
          //         Text(
          //           'Mostrando 6 de ${payments.length} pagos',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color:
          //                 widget.isDark
          //                     ? Colors.white60
          //                     : const Color(0xFF9CA3AF),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(SharedExpensePayment payment) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                widget.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: _ExpensePaymentItem(
        payment: payment,
        isDark: widget.isDark,
        expenseColor: widget.expense.categoryColor,
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

  void _showPaymentDetails(BuildContext context) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) {
    //     return _PaymentDetailsDialog(
    //       payment: payment,
    //       isDark: isDark,
    //       expenseColor: expenseColor,
    //     );
    //   },
    // );
  }

  void _showReceiptImage(BuildContext context) {
    if (payment.receiptImageUrl == null || payment.receiptImageUrl!.isEmpty) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'No hay comprobante disponible',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return;
    }

    // Aquí puedes implementar el diálogo para mostrar la imagen
    _showReceiptImageDialog(context);
  }

  void _showReceiptImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comprobante de Pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
              // Imagen
              Container(
                padding: const EdgeInsets.all(20),
                child: Image.network(
                  payment.receiptImageUrl!,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Error al cargar la imagen',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Botón de cerrar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: expenseColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPaymentDetails(context),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar del pagador con inicial
              _buildPayerAvatar(payment.payerName, context),
              const SizedBox(width: 12),

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
                          Formatters.formatCurrencyNoDecimals(payment.amount),
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
                  ],
                ),
              ),

              // Espacio para "Comprobante" e indicador
              if (payment.receiptImageUrl != null &&
                  payment.receiptImageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => _showReceiptImage(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, size: 10, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'Comprobante',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color:
                            isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayerAvatar(String payerName, BuildContext context) {
    // Usar el expenseColor (color de la categoría) con baja opacidad para el fondo
    final backgroundColor = expenseColor.withOpacity(0.1);

    // Obtener la primera letra del nombre
    String initial = payerName.isNotEmpty ? payerName[0].toUpperCase() : '?';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle, // Solo esto, sin borderRadius
      ),
      child: Center(
        child: Stack(
          children: [
            // Texto con la inicial
            Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: expenseColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Indicador de recibo (si existe)
            if (payment.receiptImageUrl != null &&
                payment.receiptImageUrl!.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle, // Cambiar aquí también
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.photo, size: 6, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
