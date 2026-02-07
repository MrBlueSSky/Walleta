// widgets/common/draggable_to_delete_card.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Callbacks para el arrastre
typedef OnDragStateChanged = void Function(bool isDragging);
typedef OnDeleteConfirmed = void Function();
typedef OnCardTap = void Function();

class DraggableToDeleteCard extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final OnDeleteConfirmed onDeleteConfirmed;
  final OnCardTap onCardTap;
  final OnDragStateChanged? onDragStateChanged;
  final String deleteDialogTitle;
  final String deleteDialogMessage;
  final Color? deleteOverlayColor;
  final bool showDeleteConfirmation;

  const DraggableToDeleteCard({
    super.key,
    required this.child,
    required this.isDark,
    required this.onDeleteConfirmed,
    required this.onCardTap,
    this.onDragStateChanged,
    this.deleteDialogTitle = '¿Eliminar?',
    this.deleteDialogMessage = 'Esta acción no se puede deshacer.',
    this.deleteOverlayColor,
    this.showDeleteConfirmation = true,
  });

  @override
  State<DraggableToDeleteCard> createState() => _DraggableToDeleteCardState();
}

class _DraggableToDeleteCardState extends State<DraggableToDeleteCard> {
  bool _isDragging = false;
  bool _isDeleting = false;
  bool _showOriginalPlaceholder = false;
  Offset _dragOffset = Offset.zero;
  OverlayEntry? _draggingCardOverlay;
  GlobalKey _cardKey = GlobalKey();
  Offset _cardPosition = Offset.zero;
  Size _cardSize = Size.zero;

  @override
  void dispose() {
    _removeDraggingCardOverlay();
    super.dispose();
  }

  void _removeDraggingCardOverlay() {
    if (_draggingCardOverlay != null) {
      _draggingCardOverlay!.remove();
      _draggingCardOverlay = null;
    }
  }

  void _createDraggingCardOverlay() {
    if (_draggingCardOverlay != null) return;

    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _cardPosition = renderBox.localToGlobal(Offset.zero);
    _cardSize = renderBox.size;

    _draggingCardOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: _cardPosition.dx + _dragOffset.dx,
          top: _cardPosition.dy + _dragOffset.dy,
          width: _cardSize.width,
          child: Opacity(
            opacity: 0.95,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        _isDeleting
                            ? Colors.red.withOpacity(0.8)
                            : widget.isDark
                            ? const Color(0xFF334155).withOpacity(0.3)
                            : const Color(0xFFE5E7EB).withOpacity(0.8),
                    width: _isDeleting ? 2 : 1,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_draggingCardOverlay!);
  }

  void _startDragging(LongPressStartDetails details) {
    setState(() {
      _showOriginalPlaceholder = true;
    });

    _createDraggingCardOverlay();

    setState(() {
      _isDragging = true;
    });

    widget.onDragStateChanged?.call(true);
  }

  void _stopDragging() {
    _removeDraggingCardOverlay();

    setState(() {
      _showOriginalPlaceholder = false;
      _isDragging = false;
      _dragOffset = Offset.zero;
      _isDeleting = false;
    });

    widget.onDragStateChanged?.call(false);
  }

  void _onDragUpdate(LongPressMoveUpdateDetails details) {
    final renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    setState(() {
      _dragOffset = Offset(
        details.localPosition.dx - (_cardSize.width / 2),
        details.localPosition.dy - (_cardSize.height / 2),
      );

      _cardPosition = renderBox.localToGlobal(Offset.zero);

      if (_draggingCardOverlay != null) {
        _draggingCardOverlay!.markNeedsBuild();
      }

      final screenHeight = MediaQuery.of(context).size.height;
      final dragY = details.globalPosition.dy;

      _isDeleting = dragY > screenHeight - 120;
    });
  }

  Future<void> _handleDelete() async {
    if (!widget.showDeleteConfirmation) {
      widget.onDeleteConfirmed();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              widget.deleteDialogTitle,
              style: TextStyle(
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              widget.deleteDialogMessage,
              style: TextStyle(
                color: widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color:
                        widget.isDark
                            ? Colors.white70
                            : const Color(0xFF6B7280),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      widget.onDeleteConfirmed();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      height: _cardSize.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB).withOpacity(0.8),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Icon(
          Iconsax.receipt,
          size: 32,
          color: widget.isDark ? Colors.white30 : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _cardKey,
      onLongPressStart: _startDragging,
      onLongPressEnd: (details) {
        if (_isDeleting) {
          _handleDelete();
        }
        _stopDragging();
      },
      onLongPressCancel: _stopDragging,
      onLongPressMoveUpdate: _onDragUpdate,
      onTap: () {
        if (!_isDragging) {
          widget.onCardTap();
        }
      },
      child: _showOriginalPlaceholder ? _buildPlaceholder() : widget.child,
    );
  }
}
