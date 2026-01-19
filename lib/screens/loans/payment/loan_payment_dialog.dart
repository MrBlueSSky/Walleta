import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walleta/models/loan.dart';

class PaymentDialog extends StatefulWidget {
  final Loan loan;
  final bool isDark;
  final int selectedTab;
  final Function(
    Loan updatedLoan,
    double paymentAmount,
    File? receiptImage,
    String? note,
  )?
  onPaymentConfirmed;

  const PaymentDialog({
    super.key,
    required this.loan,
    required this.isDark,
    required this.selectedTab,
    this.onPaymentConfirmed,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  late TextEditingController _paymentAmountController;
  late TextEditingController _noteController;
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _paymentAmountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    if (mounted) {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  bool _validateForm() {
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
      return false;
    }

    final double paymentAmount = double.parse(_paymentAmountController.text);
    final double remainingBalance =
        widget.loan.amount * (1 - widget.loan.progress);

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
      return false;
    }

    return true;
  }

  Future<void> _confirmPayment() async {
    if (!_validateForm()) return;

    if (mounted) {
      setState(() => _isUploading = true);
    }

    final double paymentAmount = double.parse(_paymentAmountController.text);
    final double newProgress =
        widget.loan.progress + (paymentAmount / widget.loan.amount);

    // Crear el préstamo actualizado
    // final updatedLoan = Loan(
    //   id: widget.loan.id,

    //   borrowerUserId: widget.loan.borrowerUserId,
    //   description: widget.loan.description,
    //   amount: widget.loan.amount,
    //   dueDate: widget.loan.dueDate,
    //   status: newProgress >= 1.0 ? LoanStatus.paid : LoanStatus.partial,
    //   // progress: newProgress.clamp(0.0, 1.0),
    //   color: widget.loan.color,
    //   type: LoanType.iOwe,
    //   paidAmount: widget.loan.paidAmount + paymentAmount, lenderUserId: ,
    // );

    // Llamar al callback si existe
    if (widget.onPaymentConfirmed != null) {
      await widget.onPaymentConfirmed!(
        widget.loan,
        paymentAmount,
        _selectedImage,
        _noteController.text.isNotEmpty ? _noteController.text : null,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.loan.borrowerUserId.name,
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
                    _buildBalanceInfo(),
                    const SizedBox(height: 20),

                    // Campo de monto del pago
                    _buildPaymentAmountField(),
                    const SizedBox(height: 20),

                    // Campo de comprobante de pago (imagen)
                    _buildReceiptImageField(),
                    const SizedBox(height: 24),

                    // Campo de descripción opcional
                    _buildNoteField(),
                    const SizedBox(height: 32),

                    // Botones de acción
                    _buildActionButtons(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
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
                      widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₡${(widget.loan.amount * (1 - widget.loan.progress)).toInt()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
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
                      widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₡${widget.loan.amount.toInt()}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color:
                      widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monto del pago',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
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
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 16,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  color:
                      widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                  fontSize: 16,
                  height: 1.2,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 8),
                  child: Icon(
                    Iconsax.money,
                    size: 20,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                suffixText: '₡',
                suffixStyle: TextStyle(
                  color:
                      widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptImageField() {
    return Column(
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
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Text(
              '(Opcional)',
              style: TextStyle(
                fontSize: 12,
                color: widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
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
                        ? const Color(0xFF334155).withOpacity(0.3)
                        : const Color(0xFFE5E7EB),
                width: 1.5,
                style: BorderStyle.solid,
              ),
            ),
            child:
                _selectedImage == null
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
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
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2D5BFF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _removeImage,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFFF6B6B),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Iconsax.trash,
                                      size: 16,
                                      color: Color(0xFFFF6B6B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color(0xFFFF6B6B),
                                        fontWeight: FontWeight.w600,
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
            color: widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
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
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Text(
              '(Opcional)',
              style: TextStyle(
                fontSize: 12,
                color: widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
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
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Ej: Pago parcial, referencia bancaria, etc.',
                hintStyle: TextStyle(
                  color:
                      widget.isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isUploading ? null : _confirmPayment,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
