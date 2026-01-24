// dialogs/register_payment_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPaymentDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final double totalAmount;
  final double paidAmount;
  final bool isDark;
  final Function(double amount, String? note, File? image) onPaymentConfirmed;
  final Function()? onCancel;

  const RegisterPaymentDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.totalAmount,
    required this.paidAmount,
    required this.isDark,
    required this.onPaymentConfirmed,
    this.onCancel,
  }) : super(key: key);

  @override
  State<RegisterPaymentDialog> createState() => _RegisterPaymentDialogState();
}

class _RegisterPaymentDialogState extends State<RegisterPaymentDialog> {
  late TextEditingController _paymentAmountController;
  File? _selectedImage;
  bool _isUploading = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _paymentAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _handlePayment() async {
    // Validar monto
    if (_paymentAmountController.text.isEmpty ||
        double.tryParse(_paymentAmountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa un monto válido'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final double paymentAmount = double.parse(_paymentAmountController.text);
    final double remainingBalance = widget.totalAmount - widget.paidAmount;

    if (paymentAmount > remainingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'El monto no puede ser mayor al saldo pendiente (₡${remainingBalance.toInt()})',
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (paymentAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El monto debe ser mayor a cero'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await widget.onPaymentConfirmed(
        paymentAmount,
        _noteController.text.isEmpty ? null : _noteController.text,
        _selectedImage,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar pago: $e'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = widget.totalAmount - widget.paidAmount;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color:
                              widget.isDark
                                  ? Colors.white30
                                  : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      'Registrar Pago',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            widget.isDark
                                ? Colors.white
                                : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            widget.isDark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información del saldo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            widget.isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo pendiente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      widget.isDark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₡${remainingBalance.toInt()}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      widget.isDark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Monto total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      widget.isDark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₡${widget.totalAmount.toInt()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      widget.isDark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Campo de monto del pago
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monto del pago',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                widget.isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  widget.isDark
                                      ? const Color(0xFF334155).withOpacity(0.3)
                                      : const Color(0xFFE5E7EB),
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _paymentAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color:
                                    widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                fontSize: 16,
                                height: 1.2,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color:
                                      widget.isDark
                                          ? Colors.white60
                                          : const Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 8,
                                  ),
                                  child: Icon(
                                    Iconsax.money,
                                    size: 20,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                suffixText: '₡',
                                suffixStyle: TextStyle(
                                  color:
                                      widget.isDark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Campo de comprobante de pago (imagen)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Comprobante de pago',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              '(Opcional)',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isDark
                                        ? Colors.white60
                                        : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color:
                                  widget.isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    widget.isDark
                                        ? const Color(
                                          0xFF334155,
                                        ).withOpacity(0.3)
                                        : const Color(0xFFE5E7EB),
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child:
                                _selectedImage == null
                                    ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Iconsax.gallery_add,
                                            size: 40,
                                            color:
                                                widget.isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF6B7280),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Agregar imagen',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  widget.isDark
                                                      ? Colors.white70
                                                      : const Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Toca para seleccionar de la galería',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  widget.isDark
                                                      ? Colors.white60
                                                      : const Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 150,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(
                                                  _selectedImage!,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: _pickImage,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFF2D5BFF,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                child: const Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.gallery,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Cambiar imagen',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              OutlinedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _selectedImage = null;
                                                  });
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: const Color(
                                                      0xFFFF6B6B,
                                                    ),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Iconsax.trash,
                                                      size: 16,
                                                      color: const Color(
                                                        0xFFFF6B6B,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Eliminar',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: const Color(
                                                          0xFFFF6B6B,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sube una foto del comprobante de pago (transferencia, recibo, etc.)',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                widget.isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Campo de descripción opcional
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nota adicional',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              '(Opcional)',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    widget.isDark
                                        ? Colors.white60
                                        : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                widget.isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  widget.isDark
                                      ? const Color(0xFF334155).withOpacity(0.3)
                                      : const Color(0xFFE5E7EB),
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              controller: _noteController,
                              maxLines: 3,
                              style: TextStyle(
                                color:
                                    widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Ej: Pago parcial, referencia bancaria, etc.',
                                hintStyle: TextStyle(
                                  color:
                                      widget.isDark
                                          ? Colors.white60
                                          : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botones de acción
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isUploading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Confirmar pago',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed:
                          widget.onCancel ?? () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              widget.isDark
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
