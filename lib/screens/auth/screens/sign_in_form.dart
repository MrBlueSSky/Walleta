import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/screens/auth/screens/forgot_password.dart';
import 'package:walleta/widgets/buttons/sign_in_submit.dart';
import 'package:walleta/widgets/inputs/sign_in_text_field.dart';

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
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggeredController,
          curve: Interval(
            index * 0.2,
            0.2 + index * 0.2,
            curve: Curves.easeOut,
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
    if (_formKey.currentState!.validate()) {
      // Solo cambiar a loading si no está ya cargando
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });

        context.read<AuthenticationBloc>().add(
          AuthenticationUserSignIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        // Siempre resetear loading cuando cambie el estado
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
        }

        if (state.status == AuthenticationStatus.error) {
          _showErrorSnackBar(
            state.errorMessage ?? 'Ocurrió un error inesperado',
          );
        }
        // No necesitamos manejar los otros estados aquí ya que _isLoading ya se resetea arriba
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeTransition(
              opacity: _itemAnimations[0],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(_itemAnimations[0]),
                child: SignInTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.white70,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Se requiere correo electrónico';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Introduzca una dirección de correo electrónico válida';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            FadeTransition(
              opacity: _itemAnimations[1],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(_itemAnimations[1]),
                child: SignInTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  obscureText: !_isPasswordVisible,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.white70,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Se requiere contraseña';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: FadeTransition(
                opacity: _itemAnimations[1],
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ForgotPasswordDialog(),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    minimumSize: const Size(10, 20),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '¿Has olvidado tu contraseña?',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            FadeTransition(
              opacity: _itemAnimations[2],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(_itemAnimations[2]),
                child: SignInSubmitButton(
                  isLoading: _isLoading,
                  text: 'Iniciar Sesión',
                  onPressed: _submitForm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
