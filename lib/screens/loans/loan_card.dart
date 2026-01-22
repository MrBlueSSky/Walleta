import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/screens/loans/details/details_content.dart';
import 'package:walleta/screens/loans/payment/loan_payment_dialog.dart';

class LoanCard extends StatefulWidget {
  const LoanCard({
    super.key,
    required this.loan,
    required this.isDark,
    required this.selectedTab,
    required this.iOwe,
  });

  final Loan loan;
  final bool isDark;
  final int selectedTab;
  final List<Loan> iOwe;

  @override
  State<LoanCard> createState() => _LoanCardState();
}

class _LoanCardState extends State<LoanCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
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
              widget.isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB).withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLoanDetails(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: widget.loan.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getInitial(
                                widget.loan.borrowerUserId.name,
                              ), // ← CORREGIDO
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.loan.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.loan.borrowerUserId.name.isNotEmpty
                                  ? widget.loan.borrowerUserId.name
                                  : 'Sin nombre', // ← Añadir fallback
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              widget.loan.description,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.loan.color.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        widget.loan.status.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.loan.color,
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
                          '₡${widget.loan.amount.toInt()}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Monto total',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                widget.isDark
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
                          '${widget.loan.dueDate.day.toString().padLeft(2, '0')} ${_monthString(widget.loan.dueDate.month)} ${widget.loan.dueDate.year}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Vence',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                widget.isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // BARRA DE PROGRESO ANIMADA
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutQuart,
                  tween: Tween<double>(begin: 0.0, end: widget.loan.progress),
                  builder: (context, value, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            widget.isDark
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
                          // Fondo
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  widget.isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF3F4F6),
                            ),
                          ),
                          // Barra de progreso animada
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    widget.loan.color,
                                    Color.lerp(
                                      widget.loan.color,
                                      Colors.white,
                                      0.2,
                                    )!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.loan.color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Efecto de brillo
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.money_send,
                          size: 14,
                          color: widget.loan.color,
                        ),
                        const SizedBox(width: 6),
                        // Porcentaje animado también
                        TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutQuart,
                          tween: IntTween(
                            begin: 0,
                            end: (widget.loan.progress * 100).toInt(),
                          ),
                          builder: (context, value, child) {
                            return Text(
                              '$value% pagado',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    // Botón condicional basado en el tab
                    if (widget.selectedTab == 1)
                      TextButton(
                        onPressed: () => _showRegisterPaymentDialog(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.add_circle,
                              size: 14,
                              color: widget.loan.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Registrar pago',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.loan.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NUEVO MÉTODO PARA OBTENER LA INICIAL SEGURA
  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  String _monthString(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    // Asegurarse de que el mes esté en rango
    if (month < 1 || month > 12) return 'Ene';
    return months[month - 1];
  }

  void _showLoanDetails() {
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
                    color:
                        widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: LoanDetailsContent(
                    context: context,
                    loan: widget.loan,
                    isDark: widget.isDark,
                    scrollController: scrollController,
                    selectedTab: widget.selectedTab,
                    onPaymentConfirmed: (updatedLoan, tabIndex, paymentAmount) {
                      // Mostrar confirmación
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: const Text('Pago registrado exitosamente'),
                      //     backgroundColor: const Color(0xFF00C896),
                      //     behavior: SnackBarBehavior.floating,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRegisterPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LoanRegisterPaymentDialog(
          loan: widget.loan,
          isDark: widget.isDark,
          selectedTab: widget.selectedTab,
          onPaymentConfirmed: (updatedLoan, tabIndex, paymentAmount) {
            // Mostrar confirmación
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     content: const Text('Pago registrado exitosamente'),
            //     backgroundColor: const Color(0xFF00C896),
            //     behavior: SnackBarBehavior.floating,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // );
          },
        );
      },
    );
  }
}
