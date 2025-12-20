import 'package:flutter/material.dart';
import 'package:walleta/widgets/utils/search_bar.dart';

class SearchButton extends StatefulWidget {
  final Color? iconColor;
  final double size;

  const SearchButton({super.key, this.iconColor, this.size = 26});

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(_controller);
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(scale: _scaleAnimation.value, child: child),
          );
        },
        child: Icon(
          Icons.search,
          size: widget.size,
          color: widget.iconColor ?? Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}
