import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_event.dart';
import 'package:walleta/blocs/payment/bloc/payment_state.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/models/payment.dart';
import 'package:walleta/screens/loans/details/detail_row.dart';
import 'package:intl/intl.dart';
import 'package:walleta/screens/loans/details/receipt_image_dialog.dart';
import 'package:walleta/utils/formatters.dart';

class LoanDetailsContent extends StatefulWidget {
  const LoanDetailsContent({
    super.key,
    required this.context,
    required this.loan,
    required this.isDark,
    required this.scrollController,
    required this.selectedTab,
    required this.onPaymentConfirmed,
  });

  final Loan loan;
  final bool isDark;
  final ScrollController scrollController;
  final int selectedTab;
  final Function(Loan, int, double) onPaymentConfirmed;

  final dynamic context;

  @override
  State<LoanDetailsContent> createState() => _LoanDetailsContentState();
}

class _LoanDetailsContentState extends State<LoanDetailsContent> {
  bool _paymentsLoaded = false;

  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  // NUEVA FUNCIÓN: Obtener el nombre a mostrar según la pestaña
  String _getDisplayName() {
    if (widget.selectedTab == 0) {
      // "Me deben" → Mostrar el nombre del deudor (borrower)
      return widget.loan.borrowerUserId.name.isNotEmpty
          ? widget.loan.borrowerUserId.name
          : 'Sin nombre';
    } else {
      // "Yo debo" → Mostrar el nombre del prestamista (lender)
      return widget.loan.lenderUserId.name.isNotEmpty
          ? widget.loan.lenderUserId.name
          : 'Sin nombre';
    }
  }

  @override
  void initState() {
    super.initState();
    // Cargar pagos cuando se inicializa el widget
    _loadPayments();
  }

  void _loadPayments() {
    if (!_paymentsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PaymentBloc>().add(LoadPayments(widget.loan.id));
        _paymentsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white30 : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // SECCIÓN CORREGIDA: Avatar y nombre
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.loan.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitial(_getDisplayName()), // ← USAR FUNCIÓN CORRECTA
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: widget.loan.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayName(), // ← USAR FUNCIÓN NUEVA
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      widget.loan.description,
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
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  widget.isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                DetailRow(
                  label: 'Monto total',

                  value: Formatters.formatCurrencyNoDecimals(
                    widget.loan.amount,
                  ),
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 12),
                DetailRow(
                  label: 'Fecha límite',
                  value: _formatDate(widget.loan.dueDate),
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 12),
                DetailRow(
                  label: 'Estado',
                  value: widget.loan.status.name,
                  isDark: widget.isDark,
                ),
                const SizedBox(height: 12),
                DetailRow(
                  label: 'Progreso',
                  value: '${(widget.loan.progress * 100).toInt()}%',
                  isDark: widget.isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color:
                  widget.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width:
                      MediaQuery.of(context).size.width * widget.loan.progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.loan.color,
                        widget.loan.color.withOpacity(0.8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // HISTORIAL DE PAGOS
          _buildPaymentHistory(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildPaymentHistory() {
    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        // Si es el estado inicial y aún no se han cargado los pagos, cargarlos
        if (state.status == PaymentStateStatus.initial && !_paymentsLoaded) {
          _loadPayments();
        }

        final loanPayments =
            state.payments.where((p) => p.loanId == widget.loan.id).toList();
        final paymentCount = loanPayments.length;

        // Determinar qué widget mostrar
        Widget content;

        if (state.status == PaymentStateStatus.loading) {
          content = const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state.status == PaymentStateStatus.error) {
          content = _buildErrorWidget();
        } else if (loanPayments.isEmpty) {
          content = _buildEmptyWidget();
        } else {
          content = _buildPaymentsList(loanPayments);
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
            content,
          ],
        );
      },
    );
  }

  Widget _buildErrorWidget() {
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
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> loanPayments) {
    return Container(
      decoration: BoxDecoration(
        color:
            widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: loanPayments.length,
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
          final payment = loanPayments[index];
          return _PaymentItem(
            payment: payment,
            isDark: widget.isDark,
            loanColor: widget.loan.color,
          );
        },
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final Payment payment;
  final bool isDark;
  final Color loanColor;

  const _PaymentItem({
    required this.payment,
    required this.isDark,
    required this.loanColor,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  void _showReceiptImage(BuildContext context) {
    if (payment.receiptImageUrl == null || payment.receiptImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No hay comprobante disponible'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Mostrar diálogo con la imagen
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
      onTap: () => _showReceiptImage(context),
      child: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono con indicador de imagen
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: loanColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Icon(Icons.credit_card, size: 20, color: loanColor),
                      if (payment.receiptImageUrl != null &&
                          payment.receiptImageUrl!.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo,
                              size: 6,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pago registrado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '₡${payment.amount.toInt()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: loanColor,
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
                            payment.receiptImageUrl!.isNotEmpty)
                          Row(
                            children: [
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
                          ),
                      ],
                    ),

                    if (payment.note != null && payment.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.note!,
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
