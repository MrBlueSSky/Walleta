import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/screens/auth/screens/forgot_password.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isRememberMe = false;

  late AnimationController _staggeredController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(
            index * 0.15,
            0.2 + index * 0.15,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _staggeredController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      context.read<AuthenticationBloc>().add(
        AuthenticationUserSignIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.warning_2, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C896),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (_isLoading) {
          setState(() => _isLoading = false);
        }

        if (state.status == AuthenticationStatus.error) {
          _showErrorSnackBar(state.errorMessage ?? 'Error al iniciar sesión');
        }

        if (state.status == AuthenticationStatus.authenticated) {
          _showSuccessSnackBar('¡Inicio de sesión exitoso!');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo de email
            _buildEmailField(isDark, isSmallScreen),
            const SizedBox(height: 20),

            // Campo de contraseña
            _buildPasswordField(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Recordar contraseña y olvidé contraseña
            _buildOptionsRow(isDark),
            const SizedBox(height: 24),

            // Botón de iniciar sesión
            _buildSubmitButton(isDark, isSmallScreen),
            const SizedBox(height: 20),

            // O continuar con
            // _buildSocialLoginSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isDark, bool isSmallScreen) {
    return FadeTransition(
      opacity: _itemAnimations[0],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(_itemAnimations[0]),
        child: Container(
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
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: isSmallScreen ? 15 : 16,
            ),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'tucorreo@ejemplo.com',
              hintStyle: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                fontSize: isSmallScreen ? 15 : 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 16 : 18,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Iconsax.sms,
                  size: 20,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Correo electrónico inválido';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(bool isDark, bool isSmallScreen) {
    return FadeTransition(
      opacity: _itemAnimations[1],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(_itemAnimations[1]),
        child: Container(
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
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              fontSize: isSmallScreen ? 15 : 16,
            ),
            decoration: InputDecoration(
              hintText: 'Tu contraseña',
              hintStyle: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                fontSize: isSmallScreen ? 15 : 16,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20,
                vertical: isSmallScreen ? 16 : 18,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Iconsax.lock_1,
                  size: 20,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                    size: 20,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                  splashRadius: 20,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsRow(bool isDark) {
    return FadeTransition(
      opacity: _itemAnimations[2],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(_itemAnimations[2]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Recordar contraseña
            GestureDetector(
              onTap: () {
                setState(() => _isRememberMe = !_isRememberMe);
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            isDark ? Colors.white30 : const Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
                      color:
                          _isRememberMe
                              ? const Color(0xFF2D5BFF)
                              : Colors.transparent,
                    ),
                    child:
                        _isRememberMe
                            ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Recordarme',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Olvidé contraseña
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ForgotPasswordDialog(),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2D5BFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark, bool isSmallScreen) {
    return FadeTransition(
      opacity: _itemAnimations[3],
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(_itemAnimations[3]),
        child: ElevatedButton(
          onPressed: _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5BFF),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isSmallScreen ? 16 : 18,
            ),
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
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Iconsax.arrow_right_3, size: 20),
                    ],
                  ),
        ),
      ),
    );
  }

  // Widget _buildSocialLoginSection(bool isDark) {
  //   return Column(
  //     children: [
  //       // Divider con texto
  //       Row(
  //         children: [
  //           Expanded(
  //             child: Divider(
  //               color:
  //                   isDark
  //                       ? const Color(0xFF334155).withOpacity(0.5)
  //                       : const Color(0xFFE5E7EB),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             child: Text(
  //               'o inicia con',
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: Divider(
  //               color:
  //                   isDark
  //                       ? const Color(0xFF334155).withOpacity(0.5)
  //                       : const Color(0xFFE5E7EB),
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 20),

  //       // Botones sociales
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           _buildSocialButton(
  //             icon: Icons.g_mobiledata,
  //             label: 'Google',
  //             isDark: isDark,
  //           ),
  //           const SizedBox(width: 12),
  //           _buildSocialButton(
  //             icon: Icons.apple,
  //             label: 'Apple',
  //             isDark: isDark,
  //           ),
  //           const SizedBox(width: 12),
  //           _buildSocialButton(
  //             icon: Icons.facebook,
  //             label: 'Facebook',
  //             isDark: isDark,
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
