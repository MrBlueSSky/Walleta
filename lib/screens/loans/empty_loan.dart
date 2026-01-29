import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EmptyLoanState extends StatelessWidget {
  const EmptyLoanState({
    this.onAddLoanPressed,
    required this.title,
    required this.isDark,
    required this.selectedTab,
    super.key,
  });

  final VoidCallback? onAddLoanPressed;

  final String title;
  final bool isDark;
  final dynamic selectedTab;

  // void _showAddLoanDialog(bool isDark) {
  //   showModalBottomSheet(
  //     context: navigatorKey.currentContext!,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return AddLoanDialog(isDark: isDark);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                title == 'Te deben' ? Iconsax.people : Iconsax.profile_2user,
                size: 48,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay registros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando tengas "$title", aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            if (selectedTab == 0)
              ElevatedButton(
                onPressed:
                    () => {
                      if (onAddLoanPressed != null) {onAddLoanPressed!()},
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add, size: 18),
                    SizedBox(width: 8),
                    Text('Agregar nuevo'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
