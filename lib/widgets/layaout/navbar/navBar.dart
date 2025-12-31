import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/buttons/animated_icon_button.dart';

class NavBar extends StatelessWidget {
  final ValueChanged<int> onTabChanged;
  final int currentIndex;

  const NavBar({
    super.key,
    required this.onTabChanged,
    required this.currentIndex,
  });

  void _onTap(int index) {
    if (currentIndex != index) {
      onTabChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // 🔥 MUCHO más arriba
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center, // ⬆️ CLAVE
        children: [
          AnimatedIconButton(
            icon: Icons.dashboard_rounded,
            size: 32,
            isSelected: currentIndex == 0,
            onPressed: () => _onTap(0),
          ),
          AnimatedIconButton(
            icon: Icons.savings_rounded,
            size: 32,
            isSelected: currentIndex == 1,
            onPressed: () => _onTap(1),
          ),
          AnimatedIconButton(
            icon: Icons.groups_rounded,
            size: 32,
            isSelected: currentIndex == 2,
            onPressed: () => _onTap(2),
          ),
          AnimatedIconButton(
            icon: Icons.handshake_rounded,
            size: 32,
            isSelected: currentIndex == 3,
            onPressed: () => _onTap(3),
          ),
          AnimatedIconButton(
            icon: Icons.person_rounded,
            size: 32,
            isSelected: currentIndex == 4,
            onPressed: () => _onTap(4),
          ),
        ],
      ),
    );
  }
}
