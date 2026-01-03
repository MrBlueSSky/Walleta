import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function() onMicPressed;
  final bool isRecording;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onMicPressed,
    this.isRecording = false,
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
  }

  @override
  void dispose() {
    _micController.dispose();
    super.dispose();
  }

  void _onMicTapDown(TapDownDetails details) {
    setState(() {
      _isMicPressed = true;
    });
    _micController.forward();
  }

  void _onMicTapUp(TapUpDetails details) {
    setState(() {
      _isMicPressed = false;
    });
    _micController.reverse();
    widget.onMicPressed();
  }

  void _onMicTapCancel() {
    setState(() {
      _isMicPressed = false;
    });
    _micController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      //!Sumarle algo para que se vea el contenedor
      height: 65 + MediaQuery.of(context).padding.bottom,
      child: Stack(
        clipBehavior:
            Clip.none, // IMPORTANTE: Permite que los hijos salgan del Stack
        children: [
          // Navbar principal (solo la parte inferior)
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
                      widget.isRecording
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
                      top: 15, // Espacio extra arriba para el micrófono
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: Row(
                      children: [
                        // Primera sección (Inicio y Transacciones)
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
                                icon: Iconsax.receipt,
                                label: 'Transacciones',
                                isActive: widget.currentIndex == 1,
                                onTap: () => widget.onTap(1),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        // Espacio para el micrófono (centro - vacío)
                        SizedBox(width: 70), // Ancho igual al micrófono
                        // Segunda sección (Compartidos y Perfil)
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

          // Micrófono FLOTANTE - POSICIONADO EN NEGATIVO para que salga del Stack
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
                    return Transform.translate(
                      // offset: Offset(0, -_micElevationAnimation.value), //!Aqui es lo que hace el efecto de elevacion
                      offset: Offset(0, 0),

                      child: Transform.scale(
                        scale:
                            widget.isRecording
                                ? _pulseAnimation.value
                                : _micScaleAnimation.value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient:
                                _isMicPressed || widget.isRecording
                                    ? const LinearGradient(
                                      colors: [
                                        Color(0xFF2D5BFF),
                                        Color(0xFF6366F1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                    : const LinearGradient(
                                      colors: [Colors.white, Color(0xFFF8FAFD)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isMicPressed || widget.isRecording
                                        ? const Color(0xFF2D5BFF)
                                        : Colors.black)
                                    .withOpacity(
                                      0.25 +
                                          (_micElevationAnimation.value / 30) *
                                              0.3,
                                    ),
                                blurRadius: 25 + _micElevationAnimation.value,
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
                                  _isMicPressed || widget.isRecording
                                      ? const Color(0xFF2D5BFF).withOpacity(0.3)
                                      : const Color(0xFFE5E7EB),
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Stack(
                              children: [
                                // Efecto de pulso cuando está grabando
                                // if (widget.isRecording)
                                //   Positioned.fill(
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         shape: BoxShape.circle,
                                //         gradient: RadialGradient(
                                //           colors: [
                                //             const Color(
                                //               0xFF2D5BFF,
                                //             ).withOpacity(0.4),
                                //             const Color(
                                //               0xFF2D5BFF,
                                //             ).withOpacity(0),
                                //           ],
                                //           stops: const [0.3, 1.0],
                                //         ),
                                //       ),
                                //     ),
                                //   ),

                                // Ícono del micrófono
                                Icon(
                                  widget.isRecording
                                      ? Iconsax.microphone_slash5
                                      : Iconsax.microphone_2,
                                  color:
                                      _isMicPressed || widget.isRecording
                                          ? Colors.white
                                          : const Color(0xFF2D5BFF),
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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
