import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/utils/formatters.dart'; // ← AGREGAR ESTA LÍNEA

// En tu archivo profile.dart, actualiza la clase PersonalExpensesCard:

class IncomesCard extends StatefulWidget {
  final VoidCallback onTap;
  final double totalExpenses;
  final double totalPaid;
  final double totalPending;
  final double progress;
  final int expenseCount;
  final Color cardColor;

  const IncomesCard({
    super.key,
    required this.onTap,
    required this.totalExpenses,
    required this.totalPaid,
    required this.totalPending,
    required this.progress,
    required this.expenseCount,
    this.cardColor = const Color(0xFF4299E1),
  });

  @override
  State<IncomesCard> createState() => _IncomesCardState();
}

class _IncomesCardState extends State<IncomesCard>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final safeProgress = widget.progress.clamp(0.0, 1.0);
    _progressAnimation = Tween<double>(begin: 0.0, end: safeProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutQuart),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(IncomesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      final safeProgress = widget.progress.clamp(0.0, 1.0);
      _progressController.animateTo(
        safeProgress,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = widget.cardColor;
    final backgroundColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _isTapped ? 0.97 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
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
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (igual que LoanCard)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Iconsax.receipt,
                                  size: 20,
                                  color: progressColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ingresos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                  ),
                                ),
                                // Text(
                                //   '${widget.incomeCount} ${widget.incomeCount == 1 ? 'ingreso' : 'ingresos'}',
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     color:
                                //         isDark
                                //             ? Colors.white70
                                //             : const Color(0xFF6B7280),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        // Porcentaje animado
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            final percentage =
                                (_progressAnimation.value * 100).toInt();
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: progressColor.withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: progressColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Montos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.formatCurrencyNoDecimals(
                                widget.totalPaid,
                              ), // ← CAMBIADO
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                                widget.totalExpenses,
                              ), // ← CAMBIADO
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Ingreso total',
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
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar animada (igual que LoanCard)
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return _buildAnimatedProgressBar(
                          _progressAnimation.value,
                          progressColor,
                          isDark,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Monto pendiente
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: widget.cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.cardColor.withOpacity(0.3),
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
                                  color: widget.cardColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pendiente: ${Formatters.formatCurrencyNoDecimals(widget.totalPending.clamp(0, double.infinity))}', // ← CAMBIADO
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.cardColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_3,
                            size: 16,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar(
    double progress,
    Color progressColor,
    bool isDark,
  ) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
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
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
            ),
          ),
          // Barra de progreso animada
          FractionallySizedBox(
            widthFactor: safeProgress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    progressColor,
                    Color.lerp(progressColor, Colors.white, 0.2)!,
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
  }
}
