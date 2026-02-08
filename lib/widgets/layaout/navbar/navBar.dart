import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function(bool) onMicPressed;
  final bool isRecording;
  final bool isPremium; // 🔥 Nuevo parámetro

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onMicPressed,
    this.isRecording = false,
    required this.isPremium, // 🔥 Nuevo parámetro requerido
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _micController;
  late Animation<double> _micScaleAnimation;
  late Animation<double> _micElevationAnimation;
  late Animation<double> _pulseAnimation;
  bool _isMicPressed = false;

  // Variables para el gesto de slide
  double _dragStartX = 0.0;
  double _dragThreshold = 30.0;

  @override
  void initState() {
    super.initState();

    _micController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _micScaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeOutCubic),
    );

    _micElevationAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _micController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _micController.repeat(reverse: true);
      } else {
        _micController.stop();
        _micController.reverse();
      }
    }

    // 🔥 Reaccionar a cambios en el estado premium
    if (widget.isPremium != oldWidget.isPremium) {
      setState(() {
        // Forzar rebuild para actualizar colores
      });
    }
  }

  @override
  void dispose() {
    _micController.dispose();
    super.dispose();
  }

  void _onMicTapDown(TapDownDetails details) {
    if (!widget.isPremium) {
      // 🔥 Mostrar feedback visual de que no está disponible
      _showPremiumRequiredFeedback();
      return;
    }

    setState(() {
      _isMicPressed = true;
    });
    _micController.forward();
    widget.onMicPressed(true);
  }

  void _onMicTapUp(TapUpDetails details) {
    if (!widget.isPremium) return;

    setState(() {
      _isMicPressed = false;
    });
    _micController.reverse();
    widget.onMicPressed(false);
  }

  void _onMicTapCancel() {
    setState(() {
      _isMicPressed = false;
    });
    _micController.reverse();
    if (widget.isPremium) {
      widget.onMicPressed(false);
    }
  }

  // 🔥 Feedback visual para función premium
  void _showPremiumRequiredFeedback() {
    _micController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _micController.reverse();
    });

    TopSnackBarOverlay.show(
      context: context,
      message: '⭐ ¡Función exclusiva para usuarios Premium!',
      backgroundColor: Colors.deepPurple,
      textColor: Colors.white,
    );
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragX = details.globalPosition.dx;
    final micCenter = screenWidth / 2;
    final micRadius = 35.0;

    if ((dragX - micCenter).abs() < micRadius) {
      return;
    }

    final dragEndX = details.globalPosition.dx;
    final dragDistance = _dragStartX - dragEndX;

    if (dragDistance.abs() > _dragThreshold) {
      if (dragDistance > 0) {
        _changeToNextPage();
      } else {
        _changeToPreviousPage();
      }
      _dragStartX = dragEndX;
    }
  }

  void _changeToNextPage() {
    final nextIndex = (widget.currentIndex + 1) % 4;
    if (nextIndex != widget.currentIndex) {
      widget.onTap(nextIndex);
    }
  }

  void _changeToPreviousPage() {
    final prevIndex = (widget.currentIndex - 1).clamp(0, 3);
    if (prevIndex != widget.currentIndex) {
      widget.onTap(prevIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;
    final premiumColor = Colors.amber; // 🔥 Color especial para premium
    const disabledColor = Color(0xFF9CA3AF);

    // 🔥 Determinar colores basados en estado premium
    final micActiveColor = widget.isPremium ? primaryColor : disabledColor;
    final micInactiveColor =
        widget.isPremium ? primaryColor.withOpacity(0.5) : disabledColor;
    final micTextColor = widget.isPremium ? Colors.white : Colors.grey[300];

    return GestureDetector(
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      excludeFromSemantics: true,
      child: SizedBox(
        height: 65 + MediaQuery.of(context).padding.bottom,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Navbar principal
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70 + MediaQuery.of(context).padding.bottom,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter:
                        widget.isRecording && widget.isPremium
                            ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.srcOver,
                            )
                            : ColorFilter.mode(
                              Colors.black.withOpacity(0.03),
                              BlendMode.srcOver,
                            ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isDark
                                ? const Color(0xFF1E293B).withOpacity(0.95)
                                : Colors.white.withOpacity(0.95),
                            isDark
                                ? const Color(0xFF1E293B).withOpacity(0.98)
                                : Colors.white.withOpacity(0.98),
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color:
                                isDark
                                    ? const Color(0xFF334155).withOpacity(0.3)
                                    : const Color(0xFFE5E7EB).withOpacity(0.8),
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: 15,
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _NavBarItem(
                                  icon: Iconsax.home_2,
                                  label: 'Inicio',
                                  isActive: widget.currentIndex == 0,
                                  onTap: () => widget.onTap(0),
                                  isDark: isDark,
                                ),
                                _NavBarItem(
                                  icon: Icons.handshake_outlined,
                                  label: 'Prestamos',
                                  isActive: widget.currentIndex == 1,
                                  onTap: () => widget.onTap(1),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 70),

                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _NavBarItem(
                                  icon: Iconsax.people,
                                  label: 'Compartidos',
                                  isActive: widget.currentIndex == 2,
                                  onTap: () => widget.onTap(2),
                                  isDark: isDark,
                                ),
                                _NavBarItem(
                                  icon: Iconsax.profile_circle,
                                  label: 'Perfil',
                                  isActive: widget.currentIndex == 3,
                                  onTap: () => widget.onTap(3),
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Micrófono
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom,
              child: Center(
                child: GestureDetector(
                  onTapDown: _onMicTapDown,
                  onTapUp: _onMicTapUp,
                  onTapCancel: _onMicTapCancel,
                  child: AnimatedBuilder(
                    animation: _micController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          // // 🔥 Badge premium (opcional)
                          // if (widget.isPremium)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 8,
                          //       vertical: 2,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: premiumColor.withOpacity(0.9),
                          //       borderRadius: BorderRadius.circular(10),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: premiumColor.withOpacity(0.3),
                          //           blurRadius: 8,
                          //           offset: const Offset(0, 2),
                          //         ),
                          //       ],
                          //     ),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Icon(
                          //           Icons.star,
                          //           size: 10,
                          //           color: Colors.white,
                          //         ),
                          //         SizedBox(width: 4),
                          //         Text(
                          //           'PREMIUM',
                          //           style: TextStyle(
                          //             fontSize: 8,
                          //             fontWeight: FontWeight.bold,
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // SizedBox(height: widget.isPremium ? 4 : 0),
                          Transform.translate(
                            offset: Offset(0, 0),
                            child: Transform.scale(
                              scale:
                                  widget.isRecording && widget.isPremium
                                      ? _pulseAnimation.value
                                      : _micScaleAnimation.value,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  gradient:
                                      _isMicPressed && widget.isPremium
                                          ? LinearGradient(
                                            colors: [
                                              micActiveColor,
                                              micActiveColor.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                          : widget.isPremium
                                          ? const LinearGradient(
                                            colors: [
                                              Colors.white,
                                              Color(0xFFF8FAFD),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                          : LinearGradient(
                                            colors: [
                                              Colors.grey[200]!,
                                              Colors.grey[300]!,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isMicPressed && widget.isPremium
                                              ? micActiveColor
                                              : widget.isPremium
                                              ? Colors.black
                                              : Colors.grey)
                                          .withOpacity(
                                            0.25 +
                                                (_micElevationAnimation.value /
                                                        30) *
                                                    0.3,
                                          ),
                                      blurRadius:
                                          25 + _micElevationAnimation.value,
                                      spreadRadius: -8,
                                      offset: Offset(
                                        0,
                                        10 + _micElevationAnimation.value / 2,
                                      ),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.9),
                                      blurRadius: 3,
                                      spreadRadius: 1.5,
                                      offset: const Offset(0, -2),
                                    ),
                                  ],
                                  border: Border.all(
                                    color:
                                        _isMicPressed && widget.isPremium
                                            ? micActiveColor.withOpacity(0.3)
                                            : widget.isPremium
                                            ? const Color(0xFFE5E7EB)
                                            : Colors.grey[400]!,
                                    width: 2.5,
                                  ),
                                ),
                                child: Center(
                                  child: Stack(
                                    children: [
                                      // Ícono principal
                                      Icon(
                                        Iconsax.microphone_2,
                                        color:
                                            widget.isPremium
                                                ? (_isMicPressed ||
                                                        widget.isRecording
                                                    ? Colors.white
                                                    : primaryColor)
                                                : disabledColor,
                                        size: 30,
                                      ),

                                      // 🔥 Indicador de bloqueo si no es premium
                                      if (!widget.isPremium)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.lock,
                                              size: 12,
                                              color: disabledColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 4,
            height: isActive ? 4 : 0,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2D5BFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            icon,
            size: 22,
            color:
                isActive
                    ? const Color(0xFF2D5BFF)
                    : isDark
                    ? Colors.white60
                    : const Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color:
                  isActive
                      ? const Color(0xFF2D5BFF)
                      : isDark
                      ? Colors.white60
                      : const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
