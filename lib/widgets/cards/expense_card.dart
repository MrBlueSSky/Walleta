import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/shared_expense.dart';

class ExpenseCard extends StatefulWidget {
  final SharedExpense expense;
  const ExpenseCard({super.key, required this.expense});

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.expense.paid / widget.expense.total;
    final isComplete = progress >= 1.0;
    final remaining = widget.expense.total - widget.expense.paid;
    final participantsCount = widget.expense.participants.length;

    // Color basado en el progreso
    Color getProgressColor(double progress) {
      if (progress <= 0.25) return const Color(0xFFFF6B6B); // rojo
      if (progress <= 0.50) return const Color(0xFFFFA726); // naranja
      if (progress <= 0.75) return const Color(0xFF2D5BFF); // azul
      if (progress < 1.0) return const Color(0xFF00C896); // verde
      return const Color(0xFF10B981); // verde éxito
    }

    final progressColor = getProgressColor(progress);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(
          16,
        ), // Cambiado a 16px como las otras
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12, // Reducido a 12px
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          // AÑADIDO: Borde sutil como las otras cards
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB).withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent, // Cambiado a transparent
        child: InkWell(
          borderRadius: BorderRadius.circular(16), // Igual que el contenedor
          onTap: () {
            // Acción al tocar la card
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Ícono y categoría
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: widget.expense.categoryColor.withOpacity(
                              0.1,
                            ), // Cambiado a color sólido con opacidad
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

                    // Estado
                    if (isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withOpacity(0.1), // Cambiado a color con opacidad
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Reducido a 12px
                          border: Border.all(
                            // Añadido borde sutil
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.tick_circle,
                              size: 12,
                              color: const Color(0xFF10B981),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pagado',
                              style: TextStyle(
                                color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: progressColor.withOpacity(
                            0.1,
                          ), // Color dinámico con opacidad
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: progressColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.clock, size: 12, color: progressColor),
                            const SizedBox(width: 4),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                color: progressColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Barra de progreso
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
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
                              // Fondo
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

                              // Progreso
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
                                              progressColor.withOpacity(0.8),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Participantes
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2D5BFF,
                                      ).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Iconsax.people,
                                      size: 12,
                                      color: Color(0xFF2D5BFF),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    participantsCount == 1
                                        ? '1 participante'
                                        : '$participantsCount participantes',
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

                              // Faltante
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
                                        '₡${remaining.toInt()}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: progressColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Lista de participantes
                if (participantsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 28,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                participantsCount > 3 ? 3 : participantsCount,
                            itemBuilder: (context, index) {
                              final participant =
                                  widget.expense.participants[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? const Color(
                                              0xFF475569,
                                            ).withOpacity(0.3)
                                            : const Color(0xFFE5E7EB),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: widget.expense.categoryColor
                                            .withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          participant
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: widget.expense.categoryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      index == 2 && participantsCount > 3
                                          ? '+${participantsCount - 3} más'
                                          : participant,
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
                              );
                            },
                          ),
                        ),
                      ],
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
