import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FilterOption extends StatelessWidget {
  const FilterOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFF2D5BFF)
                          : (isDark ? Colors.white30 : const Color(0xFFE5E7EB)),
                  width: isSelected ? 6 : 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle,
                size: 20,
                color: const Color(0xFF2D5BFF),
              ),
          ],
        ),
      ),
    );
  }
}
