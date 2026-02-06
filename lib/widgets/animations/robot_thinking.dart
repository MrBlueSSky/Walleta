import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RobotThinking extends StatelessWidget {
  const RobotThinking({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // constraints.maxWidth y constraints.maxHeight
          final maxConstraint =
              constraints.maxWidth > constraints.maxHeight
                  ? constraints.maxHeight
                  : constraints.maxWidth;

          double robotSize;

          if (maxConstraint < 400) {
            // Dispositivos muy pequeños
            robotSize = maxConstraint * 0.6;
          } else if (maxConstraint < 700) {
            // Teléfonos normales
            robotSize = maxConstraint * 0.5;
          } else if (maxConstraint < 1000) {
            // Tablets pequeñas
            robotSize = maxConstraint * 0.4;
          } else {
            // Tablets grandes / Desktop
            robotSize = maxConstraint * 0.3;
          }

          // Límites finales
          robotSize = robotSize.clamp(200.0, 500.0);

          return Center(
            child: Container(
              width: robotSize,
              height: robotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: robotSize * 0.15,
                    spreadRadius: robotSize * 0.04,
                    offset: Offset(0, robotSize * 0.03),
                  ),
                ],
              ),
              child: Lottie.asset(
                "assets/animations/robot_think.json",
                width: robotSize,
                height: robotSize,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
