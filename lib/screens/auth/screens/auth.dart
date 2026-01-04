import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/screens/auth/screens/sign_in_form.dart';
import 'package:walleta/screens/auth/screens/sign_up_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignIn = !_isSignIn;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  isDark
                      ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                      : [
                        const Color(0xFFF8FAFD),
                        Colors.white,
                        const Color(0xFFF8FAFD),
                      ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 32,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo y nombre de la app
                      _buildLogo(isDark, isSmallScreen),
                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Card principal con tabs y formulario
                      _buildAuthCard(isDark, isSmallScreen),

                      // Footer
                      _buildFooter(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark, bool isSmallScreen) {
    return Column(
      children: [
        // Logo con gradiente
        Container(
          width: isSmallScreen ? 72 : 88,
          height: isSmallScreen ? 72 : 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2D5BFF), Color(0xFF00C896)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D5BFF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Iconsax.wallet_3,
              size: isSmallScreen ? 36 : 44,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        // Nombre de la app
        Text(
          'Walleta',
          style: TextStyle(
            fontSize: isSmallScreen ? 32 : 40,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: isSmallScreen ? 4 : 8),

        // Subtítulo
        Text(
          'Tu billetera digital inteligente',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(bool isDark, bool isSmallScreen) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                offset: const Offset(0, 16),
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
          child: Column(
            children: [
              // Tabs de Iniciar Sesión / Registrarse
              _buildTabSelector(isDark, isSmallScreen),

              // Contenido del formulario
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeInOutCubic,
                  switchOutCurve: Curves.easeInOutCubic,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.vertical,
                        axisAlignment: -1,
                        child: child,
                      ),
                    );
                  },
                  child:
                      _isSignIn
                          ? SignInForm(key: const ValueKey('signin'))
                          : SignUpForm(key: const ValueKey('signup')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: 'Iniciar Sesión',
            isSignInTab: true,
            isDark: isDark,
            isSmallScreen: isSmallScreen,
          ),
          _buildTabButton(
            label: 'Registrarse',
            isSignInTab: false,
            isDark: isDark,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSignInTab,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    final isSelected =
        (isSignInTab && _isSignIn) || (!isSignInTab && !_isSignIn);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Solo cambiar si es diferente al estado actual
          if ((isSignInTab && !_isSignIn) || (!isSignInTab && _isSignIn)) {
            _toggleAuthMode();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDark
                        ? const Color(0xFF2D5BFF)
                        : const Color(0xFF2D5BFF))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: const Color(0xFF2D5BFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 14 : 16,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        // Línea divisoria
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color:
                      isDark
                          ? const Color(0xFF334155).withOpacity(0.5)
                          : const Color(0xFFE5E7EB),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o continúa con',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color:
                      isDark
                          ? const Color(0xFF334155).withOpacity(0.5)
                          : const Color(0xFFE5E7EB),
                ),
              ),
            ],
          ),
        ),

        // Botones de login social
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              iconColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.apple,
              label: 'Apple',
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              iconColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              iconColor: isDark ? Colors.white70 : const Color(0xFF6B7280),
              isDark: isDark,
            ),
          ],
        ),

        // Términos y condiciones
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            'Al continuar, aceptas nuestros Términos de Servicio\n y Política de Privacidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark
                  ? const Color(0xFF334155).withOpacity(0.5)
                  : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
