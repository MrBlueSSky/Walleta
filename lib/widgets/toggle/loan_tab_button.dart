import 'package:flutter/material.dart';

class LoanTabButton extends StatelessWidget {
  const LoanTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDark
                        ? const Color(0xFF2D5BFF)
                        : const Color(0xFF2D5BFF))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
