import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/buttons/animated_icon_button.dart';

class NavBar extends StatefulWidget {
  final ValueChanged<int> onTabChanged;
  final int currentIndex;
  const NavBar({
    super.key,
    required this.onTabChanged,
    required this.currentIndex,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  double iconsButtonsSize = 25;
  int selectedIndex = 0;

  bool _isCreateRideOpen = false;

  void onIconPressed(int index) {
    widget.onTabChanged(index);
  }

  void _openCreateRide() {
    setState(() {
      _isCreateRideOpen = true;
    });
  }

  void _closeCreateRide() {
    setState(() {
      _isCreateRideOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    // Sombra removida completamente
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Botón centrado con mejor alineación
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: RawMaterialButton(
                onPressed: () {
                  //! Acción Micorofono para agendar por comando de voz
                },
                elevation: 2.0,
                fillColor: AppColors.iconsNavBarColor,
                child: const Icon(
                  Icons.mic_none_rounded,
                  size: 30.0,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(15.0),
                shape: const CircleBorder(),
              ),
            ),
          ),
          // Iconos de navegación sin el botón del medio
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedIconButton(
                    size: iconsButtonsSize,
                    icon: Icons.home_rounded,
                    isSelected: widget.currentIndex == 0,
                    onPressed: () => onIconPressed(0),
                  ),
                  AnimatedIconButton(
                    size: iconsButtonsSize,
                    icon: Icons.chat,
                    isSelected: widget.currentIndex == 1,
                    onPressed: () => onIconPressed(1),
                  ),
                  // Espacio vacío para el botón del medio
                  const SizedBox(width: 60),
                  AnimatedIconButton(
                    size: iconsButtonsSize,
                    icon: Icons.collections_bookmark_rounded,
                    isSelected: widget.currentIndex == 2,
                    onPressed: () => onIconPressed(2),
                  ),
                  AnimatedIconButton(
                    size: iconsButtonsSize,
                    icon: Icons.person,
                    isSelected: widget.currentIndex == 3,
                    onPressed: () => onIconPressed(3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
