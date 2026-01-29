import 'package:flutter/material.dart';

class ChartEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final String actionText;
  final IconData icon;
  final Color? iconColor;

  const ChartEmptyState({
    Key? key,
    this.title = 'No hay datos disponibles',
    this.description =
        'Agrega tus gastos para ver el análisis detallado por categorías',
    this.actionText = 'Comienza a registrar gastos',
    this.icon = Icons.pie_chart_outline_rounded,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono decorativo
            Container(
              width: isSmallScreen ? 70 : 80,
              height: isSmallScreen ? 70 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: isSmallScreen ? 32 : 40,
                color: iconColor ?? theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),

            SizedBox(height: isSmallScreen ? 16 : 20),

            // Título
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // Descripción
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isSmallScreen ? 13 : 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Botón de acción (opcional)
            if (actionText.isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 20 : 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_chart_rounded,
                      size: isSmallScreen ? 14 : 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      actionText,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: isSmallScreen ? 12 : 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
