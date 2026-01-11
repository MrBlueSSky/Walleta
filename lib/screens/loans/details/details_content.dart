import 'package:flutter/material.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/screens/loans/details/register_payment.dart';
import 'package:walleta/screens/loans/details/detail_row.dart';

class LoanDetailsContent extends StatelessWidget {
  const LoanDetailsContent({
    super.key,
    required this.context,
    required this.loan,
    required this.isDark,
    required this.scrollController,
    required this.selectedTab, // Añadir este parámetro
    required this.onPaymentConfirmed, // Añadir callback
  });

  final BuildContext context;
  final LoanData loan;
  final bool isDark;
  final ScrollController scrollController;
  final int selectedTab; // Nueva propiedad
  final Function(LoanData, int, double) onPaymentConfirmed; // Nueva propiedad

  void _showRegisterPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return RegisterPaymentDialog(
          loan: loan,
          isDark: isDark,
          selectedTab: selectedTab,
          onPaymentConfirmed: onPaymentConfirmed,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
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
                color: isDark ? Colors.white30 : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: loan.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    loan.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: loan.color,
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
                      loan.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      loan.description,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
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
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                DetailRow(
                  label: 'Monto total',
                  value: '₡${loan.amount.toInt()}',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                DetailRow(
                  label: 'Fecha límite',
                  value: loan.date,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                DetailRow(label: 'Estado', value: loan.status, isDark: isDark),
                const SizedBox(height: 12),
                DetailRow(
                  label: 'Progreso',
                  value: '${(loan.progress * 100).toInt()}%',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width: double.infinity * loan.progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [loan.color, loan.color.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: loan.color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Editar',
                    style: TextStyle(
                      color: loan.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar detalles
                    _showRegisterPaymentDialog(); // Mostrar diálogo de pago
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loan.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Registrar pago',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
