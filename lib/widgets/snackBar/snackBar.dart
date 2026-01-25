// top_snackbar_overlay.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TopSnackBarOverlay {
  static void show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    IconData icon = Iconsax.warning_2,
    Duration duration = const Duration(seconds: 3),
    double verticalOffset = 70.0, // Offset desde el top
  }) {
    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    // Crear el OverlayEntry
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top:
                topPadding +
                verticalOffset, // Ajusta verticalOffset según necesites
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: _TopSnackBarContent(
                message: message,
                backgroundColor: backgroundColor,
                textColor: textColor,
                icon: icon,
                onClose: () => overlayEntry.remove(),
              ),
            ),
          ),
    );

    // Insertar en el overlay
    overlay.insert(overlayEntry);

    // Auto-remover después de la duración
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _TopSnackBarContent extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final VoidCallback onClose;

  const _TopSnackBarContent({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onClose,
  });

  @override
  State<_TopSnackBarContent> createState() => __TopSnackBarContentState();
}

class __TopSnackBarContentState extends State<_TopSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Icon(
                        Icons.close,
                        color: widget.textColor.withOpacity(0.8),
                        size: 18,
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
}
