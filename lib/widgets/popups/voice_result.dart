import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Widget para el popup personalizado
class VoiceResultPopup extends StatefulWidget {
  final Map<String, dynamic> result;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onClose;

  const VoiceResultPopup({
    Key? key,
    required this.result,
    required this.onSave,
    required this.onCancel,
    required this.onClose,
  }) : super(key: key);

  @override
  State<VoiceResultPopup> createState() => _VoiceResultPopupState();
}

class _VoiceResultPopupState extends State<VoiceResultPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Iniciar animación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final success = result['success'] == true;

    final primaryColor = Theme.of(context).primaryColor;
    const successColor = Color(0xFF10B981);
    const warningColor = Color(0xFFF59E0B);

    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _closeWithAnimation,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              // Más pequeño: máximo 80% del ancho y 65% del alto
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header compacto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: success ? primaryColor : warningColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.info,
                          color: textColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                success
                                    ? '¡Transacción detectada!'
                                    : 'Información incompleta',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                success
                                    ? 'Revisa los detalles antes de guardar'
                                    : 'Completa los datos faltantes',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _closeWithAnimation,
                          icon: Icon(Icons.close, color: textColor, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36),
                        ),
                      ],
                    ),
                  ),

                  // Contenido scrollable
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildContent(result, success),
                    ),
                  ),

                  // Footer compacto
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: textColor.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              widget.onCancel();
                              _closeWithAnimation();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                success
                                    ? () {
                                      widget.onSave();
                                      _closeWithAnimation();
                                      widget.onCancel();
                                    }
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  success ? primaryColor : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  success ? Icons.check : Icons.edit,
                                  size: 18,
                                  color: textColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Guardar',
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _buildContent(Map<String, dynamic> result, bool success) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transcripción
        if (result['transcription'] != null &&
            result['transcription'].toString().isNotEmpty)
          _buildInfoCard(
            icon: Icons.mic,
            title: 'Dijiste:',
            content: result['transcription'].toString(),
            isQuote: true,
          ),

        // Datos procesados
        if (result['data'] != null && success)
          _buildTransactionInfo(result['data']),

        // Mensaje del usuario
        if (result['message'] != null &&
            result['message'].toString().isNotEmpty)
          _buildInfoCard(
            icon: Icons.info_outline,
            title: 'Mensaje:',
            content: result['message'].toString(),
          ),

        // Error
        if (result['error'] != null)
          _buildInfoCard(
            icon: Icons.error_outline,
            title: 'Error:',
            content: result['error'].toString(),
            isError: true,
          ),

        // Estado
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: success ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: success ? Colors.green.shade100 : Colors.orange.shade100,
            ),
          ),
          child: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.warning,
                color: success ? Colors.green : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? 'Todo listo para guardar la transacción'
                      : 'Información pendiente por completar',
                  style: TextStyle(
                    color:
                        success
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    bool isQuote = false,
    bool isError = false,
  }) {
    final likeColor = Colors.blue.withOpacity(0.5);

    final color = isError ? Colors.red : Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isQuote ? '"$content"' : content,
            style: TextStyle(
              color: isError ? Colors.red.shade700 : textColor,
              fontSize: 14,
              fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo(Map<String, dynamic> data) {
    final type = data['transaction_type']?.toString() ?? '';
    final amount = data['amount'];
    final currency = data['currency']?.toString() ?? 'CRC';
    final category = data['category']?.toString() ?? '';
    final title = data['title']?.toString() ?? '';

    final color = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTransactionIcon(type),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransactionTypeText(type),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (amount != null)
                      Text(
                        '\$$amount $currency',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (title.isNotEmpty)
                _buildDetailChip(label: title, color: Colors.blue),
              if (category.isNotEmpty && category != 'other')
                _buildDetailChip(
                  label: _getCategoryText(category),
                  color: Colors.purple,
                ),
              if (data['is_shared'] == true)
                _buildDetailChip(label: 'Compartido', color: Colors.green),
              if (data['is_loan'] == true)
                _buildDetailChip(label: 'Préstamo', color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  //!Revisar estos y quiza hacer un enum para esto y todoo donde se use
  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'personal_expense':
        return Icons.monetization_on_outlined;
      case 'income':
        return Icons.attach_money;
      case 'shared_expense':
        return Icons.people;
      case 'payment_to_person':
        return Icons.person;
      case 'loan_given':
        return Icons.arrow_upward;
      case 'loan_received':
        return Icons.arrow_downward;
      case 'money_request':
        return Icons.notifications_active;
      case 'split_bill':
        return Icons.restaurant;
      default:
        return Iconsax.money_send;
    }
  }

  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'personal_expense':
        return 'Gasto personal';
      case 'income':
        return 'Ingreso';
      case 'shared_expense':
        return 'Gasto compartido';
      case 'payment_to_person':
        return 'Pago a persona';
      case 'loan_given':
        return 'Préstamo otorgado';
      case 'loan_received':
        return 'Préstamo recibido';
      case 'money_request':
        return 'Solicitud de dinero';
      case 'split_bill':
        return 'Cuenta dividida';
      default:
        return 'Transacción';
    }
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'food':
        return 'Comida';
      case 'transport':
        return 'Transporte';
      case 'housing':
        return 'Hogar';
      case 'entertainment':
        return 'Entretenimiento';
      case 'shopping':
        return 'Compras';
      case 'health':
        return 'Salud';
      case 'education':
        return 'Educación';
      case 'salary':
        return 'Salario';
      case 'business':
        return 'Negocios';
      case 'investment':
        return 'Inversión';
      case 'savings':
        return 'Ahorros';
      case 'debt':
        return 'Deudas';
      default:
        return 'Otros';
    }
  }
}
