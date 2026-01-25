import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSuccess = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        context.read<AuthenticationBloc>().add(
          AuthenticationPasswordResetRequested(
            email: _emailController.text.trim(),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });

          // Auto-cerrar después de 2 segundos
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          _showErrorSnackBar(
            e.toString().contains('PasswordResetFailure')
                ? e.toString().split(': ').last
                : 'Error al enviar el correo de recuperación',
          );
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    final screenHeight = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.warning_2, size: 18, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.only(
          bottom: screenHeight - 100,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: const Color(0xFF2D5BFF).withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color:
                          isDark
                              ? const Color(0xFF334155).withOpacity(0.3)
                              : const Color(0xFFE5E7EB).withOpacity(0.8),
                      width: 0.5,
                    ),
                  ),
                  child:
                      _isSuccess
                          ? _buildSuccessState(isDark)
                          : _buildFormState(isDark),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(isDark),
            const SizedBox(height: 20),

            // Instrucciones
            _buildInstructions(isDark),
            const SizedBox(height: 24),

            // Campo de email
            _buildEmailField(isDark),
            const SizedBox(height: 24),

            // Botón de acción
            _buildSubmitButton(isDark),
            const SizedBox(height: 8),

            // Botón cancelar
            _buildCancelButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2D5BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Iconsax.lock_slash,
            size: 24,
            color: const Color(0xFF2D5BFF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recuperar Contraseña',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Iconsax.close_circle,
            size: 22,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          splashRadius: 20,
        ),
      ],
    );
  }

  Widget _buildInstructions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.info_circle,
              size: 18,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              'Pasos a seguir:',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep(
                number: '1',
                text: 'Ingresa tu correo electrónico',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildStep(
                number: '2',
                text: 'Te enviaremos un enlace de recuperación',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildStep(
                number: '3',
                text: 'Revisa tu bandeja de entrada',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF2D5BFF),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.5)
                  : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'tuemail@ejemplo.com',
          hintStyle: TextStyle(
            color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Iconsax.sms,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          errorStyle: TextStyle(color: const Color(0xFFFF6B6B), fontSize: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Ingresa tu correo electrónico';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Correo electrónico inválido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _resetPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D5BFF),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: const Color(0xFF2D5BFF).withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child:
          _isLoading
              ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enviar Enlace de Recuperación',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Icon(Iconsax.send_2, size: 18),
                ],
              ),
    );
  }

  Widget _buildCancelButton(bool isDark) {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        'Cancelar',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de éxito
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00C896), Color(0xFF2D5BFF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.tick_circle,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Título
          Text(
            '¡Correo enviado!',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Mensaje
          Text(
            'Hemos enviado un enlace de recuperación a tu correo electrónico. Revisa tu bandeja de entrada y sigue las instrucciones.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Iconos de check
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    size: 16,
                    color: const Color(0xFF00C896),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Correo enviado',
                    style: TextStyle(
                      color: const Color(0xFF00C896),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    size: 16,
                    color: const Color(0xFF00C896),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Revisa tu bandeja',
                    style: TextStyle(
                      color: const Color(0xFF00C896),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Botón para cerrar
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              foregroundColor: isDark ? Colors.white : const Color(0xFF1F2937),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(
              'Entendido',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
