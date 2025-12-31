import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';

class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isSelected;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.isSelected,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.iconsNavBarColor
        : AppColors.primaryLight;

    return GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.icon,
              size: widget.size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
