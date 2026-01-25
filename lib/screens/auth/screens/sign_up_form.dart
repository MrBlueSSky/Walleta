import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  late AnimationController _staggeredController;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();

    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Crear 8 animaciones para cada sección del formulario
    _itemAnimations = List.generate(
      8,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(
            index * 0.1,
            0.2 + index * 0.1,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _staggeredController.forward();
  }

  @override
  void dispose() {
    _username.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _staggeredController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _acceptTerms && !_isLoading) {
      setState(() => _isLoading = true);

      context.read<AuthenticationBloc>().add(
        AuthenticationUserRegister(
          username: _username.text.trim(),
          name: _firstNameController.text.trim(),
          surname: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          profilePictureUrl: '',
        ),
      );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Iconsax.warning_2, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Debes aceptar los términos y condiciones'),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.warning_2, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF00C896),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
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
          _showErrorSnackBar(
            state.errorMessage ?? 'Error en el registro. Inténtalo de nuevo.',
          );
        }

        if (state.status == AuthenticationStatus.authenticated) {
          _showSuccessSnackBar('¡Registro exitoso!');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre de usuario
            _buildUsernameField(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Nombre y Apellido (en fila en pantallas grandes)
            _buildNameFields(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Teléfono
            _buildPhoneField(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Email
            _buildEmailField(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Contraseña y Confirmar contraseña
            _buildPasswordFields(isDark, isSmallScreen),
            const SizedBox(height: 16),

            // Términos y condiciones
            _buildTermsCheckbox(isDark),
            const SizedBox(height: 24),

            // Botón de registro
            _buildSubmitButton(isDark, isSmallScreen),
            const SizedBox(height: 20),

            // Ya tienes una cuenta
            // _buildLoginLink(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField(bool isDark, bool isSmallScreen) {
    return _buildAnimatedField(
      animation: _itemAnimations[0],
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
          controller: _username,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: isSmallScreen ? 15 : 16,
          ),
          decoration: InputDecoration(
            hintText: 'tu_usuario',
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
                Iconsax.user,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa un nombre de usuario';
            }
            if (value.length < 3) {
              return 'Mínimo 3 caracteres';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildNameFields(bool isDark, bool isSmallScreen) {
    final isLargeScreen = MediaQuery.of(context).size.width > 500;

    if (isLargeScreen) {
      return _buildAnimatedField(
        animation: _itemAnimations[1],
        child: Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                hint: 'Nombre',
                icon: Iconsax.user_add,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu nombre';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                hint: 'Apellido',
                icon: Iconsax.user_add,
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu apellido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          _buildAnimatedField(
            animation: _itemAnimations[1],
            child: _buildTextField(
              controller: _firstNameController,
              hint: 'Nombre',
              icon: Iconsax.user_add,
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu nombre';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedField(
            animation: _itemAnimations[2],
            child: _buildTextField(
              controller: _lastNameController,
              hint: 'Apellido',
              icon: Iconsax.user_add,
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu apellido';
                }
                return null;
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPhoneField(bool isDark, bool isSmallScreen) {
    return _buildAnimatedField(
      animation: _itemAnimations[3],
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
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: isSmallScreen ? 15 : 16,
          ),
          decoration: InputDecoration(
            hintText: '+506 1234 5678',
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
                Iconsax.call,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu número de teléfono';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildEmailField(bool isDark, bool isSmallScreen) {
    return _buildAnimatedField(
      animation: _itemAnimations[4],
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
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: isSmallScreen ? 15 : 16,
          ),
          decoration: InputDecoration(
            hintText: 'tuemail@ejemplo.com',
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
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Correo electrónico inválido';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildPasswordFields(bool isDark, bool isSmallScreen) {
    final isLargeScreen = MediaQuery.of(context).size.width > 500;

    if (isLargeScreen) {
      return _buildAnimatedField(
        animation: _itemAnimations[5],
        child: Row(
          children: [
            Expanded(
              child: _buildPasswordTextField(
                controller: _passwordController,
                hint: 'Contraseña',
                isPasswordVisible: _isPasswordVisible,
                onToggleVisibility: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPasswordTextField(
                controller: _confirmPasswordController,
                hint: 'Confirmar contraseña',
                isPasswordVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () {
                  setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  );
                },
                isDark: isDark,
                isSmallScreen: isSmallScreen,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          _buildAnimatedField(
            animation: _itemAnimations[5],
            child: _buildPasswordTextField(
              controller: _passwordController,
              hint: 'Contraseña',
              isPasswordVisible: _isPasswordVisible,
              onToggleVisibility: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                if (value.length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildAnimatedField(
            animation: _itemAnimations[6],
            child: _buildPasswordTextField(
              controller: _confirmPasswordController,
              hint: 'Confirmar contraseña',
              isPasswordVisible: _isConfirmPasswordVisible,
              onToggleVisibility: () {
                setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                );
              },
              isDark: isDark,
              isSmallScreen: isSmallScreen,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required bool isSmallScreen,
    required String? Function(String?)? validator,
  }) {
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
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontSize: isSmallScreen ? 15 : 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
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
              icon,
              size: 20,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String hint,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
    required bool isDark,
    required bool isSmallScreen,
    required String? Function(String?)? validator,
  }) {
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
        controller: controller,
        obscureText: !isPasswordVisible,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1F2937),
          fontSize: isSmallScreen ? 15 : 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
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
                isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                size: 20,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
              onPressed: onToggleVisibility,
              splashRadius: 20,
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return _buildAnimatedField(
      animation: _itemAnimations[6],
      child: GestureDetector(
        onTap: () {
          setState(() => _acceptTerms = !_acceptTerms);
        },
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.white30 : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
                color:
                    _acceptTerms ? const Color(0xFF2D5BFF) : Colors.transparent,
              ),
              child:
                  _acceptTerms
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'Términos de Servicio',
                      style: TextStyle(
                        color: const Color(0xFF2D5BFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: TextStyle(
                        color: const Color(0xFF2D5BFF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark, bool isSmallScreen) {
    return _buildAnimatedField(
      animation: _itemAnimations[7],
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D5BFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFF2D5BFF).withOpacity(0.3),
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
                      'Crear Cuenta',
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
    );
  }

  Widget _buildLoginLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta? ',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Aquí deberías tener una forma de cambiar a SignIn
            // Depende de cómo manejes el AuthScreen
          },
          child: Text(
            'Inicia Sesión',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D5BFF),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedField({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
