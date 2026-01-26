import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/utils/formatters.dart'; // ← AGREGAR ESTA LÍNEA

class SavingsCard extends StatefulWidget {
  final VoidCallback onTap;
  final double currentSavings;
  final double monthlyGoal;
  final Color cardColor;

  const SavingsCard({
    super.key,
    required this.onTap,
    required this.currentSavings,
    required this.monthlyGoal,
    this.cardColor = const Color(0xFF00C896),
  });

  @override
  State<SavingsCard> createState() => _SavingsCardState();
}

class _SavingsCardState extends State<SavingsCard>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  double get progress =>
      widget.monthlyGoal > 0
          ? (widget.currentSavings / widget.monthlyGoal).clamp(0.0, 1.0)
          : 0.0;

  // String get formattedCurrentSavings =>
  //     '₡${widget.currentSavings.toStringAsFixed(0)}'; // ← ELIMINAR
  // String get formattedMonthlyGoal =>
  //     '₡${widget.monthlyGoal.toStringAsFixed(0)}'; // ← ELIMINAR

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: progress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutQuart),
    );

    // Iniciar animación después de un pequeño delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(SavingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSavings != widget.currentSavings ||
        oldWidget.monthlyGoal != widget.monthlyGoal) {
      _progressController.animateTo(
        progress,
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.savings_outlined,
                                color: progressColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mis Ahorros',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: progressColor,
                                  ),
                                ),
                                Text(
                                  'Meta mensual',
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
                        // Porcentaje animado
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
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
                                '${(_progressAnimation.value * 100).toInt()}%',
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

                    // Amounts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Formatters.formatCurrencyNoDecimals(
                                widget.currentSavings,
                              ), // ← CAMBIADO
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Ahorro actual',
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
                                widget.monthlyGoal,
                              ), // ← CAMBIADO
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'Meta total',
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

                    // Progress Bar MEJORADA
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

                    // Remaining amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Iconsax.money_send,
                                size: 12,
                                color: progressColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Faltan: ${Formatters.formatCurrencyNoDecimals((widget.monthlyGoal - widget.currentSavings).clamp(0, double.infinity))}', // ← CAMBIADO
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF6B7280),
                        ),
                      ],
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
            widthFactor: progress,
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
            ),
          ),
          // Efecto de brillo
          if (progress > 0)
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                    stops: const [0.0, 0.3],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
