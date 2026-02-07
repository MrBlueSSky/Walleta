// widgets/common/trash_overlay.dart
import 'package:flutter/material.dart';

class TrashOverlayController {
  void showOverlay(BuildContext context) {
    _showTrashOverlay(context);
  }

  void hideOverlay() {
    _removeTrashOverlay();
  }

  static OverlayEntry? _trashOverlayEntry;
  static bool _isShowing = false;

  static void _showTrashOverlay(BuildContext context) {
    if (_trashOverlayEntry != null || _isShowing) return;

    _isShowing = true;
    _trashOverlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 160,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // Acción de eliminar
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Eliminar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_trashOverlayEntry!);
  }

  static void _removeTrashOverlay() {
    if (_trashOverlayEntry != null) {
      _trashOverlayEntry!.remove();
      _trashOverlayEntry = null;
      _isShowing = false;
    }
  }
}
