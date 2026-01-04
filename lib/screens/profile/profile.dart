import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/screens/savings/savings_account.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/cards/savings_card.dart';
import 'package:walleta/widgets/layaout/appbar/drawer/custom_drawer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 60 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 60 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _openDrawer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => CustomDrawer(
              onClose: () => Navigator.of(context).pop(),
              onItemSelected: _handleDrawerItemSelection,
            ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _handleDrawerItemSelection(String item) {
    Navigator.of(context).pop();

    switch (item) {
      case 'saved':
        _showPlaceholderDialog('Saved');
        break;
      case 'activity':
        _showPlaceholderDialog('Your Activity');
        break;
      case 'notifications':
        _showPlaceholderDialog('Notifications');
        break;
      case 'insights':
        _showPlaceholderDialog('Insights');
        break;
      case 'verified':
        _showPlaceholderDialog('Verified');
        break;
      case 'logout':
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
        break;
    }
  }

  void _showPlaceholderDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: Text(
              feature,
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Esta función estará disponible próximamente.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _openSavingsScreen(BuildContext context) {
    // Si ya tienes una pantalla de ahorros llamada 'SavingsScreen'
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SavingsAccountScreen(), // Reemplaza con tu pantalla
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  // O con una animación de zoom/modal:
  // void _openSavingsScreenWithModalAnimation(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) {
  //       return GestureDetector(
  //         onTap: () => Navigator.pop(context),
  //         behavior: HitTestBehavior.opaque,
  //         child: Container(
  //           color: Colors.black.withOpacity(0.5),
  //           child: DraggableScrollableSheet(
  //             initialChildSize: 0.9,
  //             minChildSize: 0.5,
  //             maxChildSize: 0.95,
  //             builder: (context, scrollController) {
  //               return Container(
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).scaffoldBackgroundColor,
  //                   borderRadius: const BorderRadius.vertical(
  //                     top: Radius.circular(24),
  //                   ),
  //                 ),
  //                 child: SavingsScreen(), // Reemplaza con tu pantalla
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // O con una animación personalizada tipo "hero":
  void _openSavingsScreenWithHeroAnimation(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => SavingsAccountScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var scaleTween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var fadeTween = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.unauthenticated) {
            return const _UnauthenticatedView();
          }

          final user = state.user;
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar personalizado - SIN FECHA DE RETROCESO
              SliverAppBar(
                expandedHeight: screenHeight * 0.25,
                floating: false,
                pinned: true,
                snap: false,
                stretch: true,
                backgroundColor:
                    isDark
                        ? const Color(
                          0xFF1E293B,
                        ).withOpacity(_isScrolled ? 0.95 : 0)
                        : Colors.white.withOpacity(_isScrolled ? 0.95 : 0),
                elevation: _isScrolled ? 4 : 0,
                shadowColor: Colors.black.withOpacity(0.1),
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading:
                    false, // IMPORTANTE: No mostrar flecha automática
                actions: [
                  IconButton(
                    icon: Icon(
                      Iconsax.menu_1,
                      color:
                          _isScrolled
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937))
                              : Colors.white,
                    ),
                    onPressed: _openDrawer,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title:
                      _isScrolled
                          ? Text(
                            'Mi Perfil',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : null,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          //!Aqui va los colores del gradiente
                          const Color(0xFF0F172A),
                          const Color(0xFF1E293B),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildProfileImage(user.profilePictureUrl),
                          const SizedBox(height: 12),
                          _buildUserName(user.name, user.surname),
                          const SizedBox(height: 4),
                          _buildUserEmail(user.email),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Sección de estadísticas
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 20,
              //     ),
              //     child: _buildStatsSection(user),
              //   ),
              // ),
              SliverToBoxAdapter(child: const SizedBox(height: 20)),

              // Sección de información personal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildPersonalInfoSection(user),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: SavingsCard(
                    onTap: () => _openSavingsScreenWithHeroAnimation(context),
                    currentSavings: 25430, // Tu valor real
                    monthlyGoal: 80000, // Tu valor real
                  ),
                ),
              ),

              // Sección de métricas financieras
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 20,
              //     ),
              //     child: _buildFinancialMetrics(),
              //   ),
              // ),

              // Espacio al final
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFF3F4F6),
        child:
            hasImage
                ? ClipOval(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                )
                : const Icon(
                  Iconsax.profile_circle,
                  size: 50,
                  color: Color(0xFF2D5BFF),
                ),
      ),
    );
  }

  Widget _buildUserName(String name, String surname) {
    final fullName = '$name $surname'.trim();

    return Text(
      fullName.isNotEmpty ? fullName : 'Usuario',
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserEmail(String email) {
    return Text(
      email,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Widget _buildStatsSection(AppUser user) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF1E293B) : Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 12,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //       border: Border.all(
  //         color:
  //             isDark
  //                 ? const Color(0xFF334155).withOpacity(0.3)
  //                 : const Color(0xFFE5E7EB).withOpacity(0.8),
  //         width: 0.5,
  //       ),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: [
  //           _buildStatItem(
  //             icon: Iconsax.wallet_3,
  //             value: '₡125,430',
  //             label: 'Balance',
  //             color: const Color(0xFF00C896),
  //           ),
  //           _buildVerticalDivider(),
  //           _buildStatItem(
  //             icon: Iconsax.arrow_up_2,
  //             value: '₡150,000',
  //             label: 'Ingresos',
  //             color: const Color(0xFF2D5BFF),
  //           ),
  //           _buildVerticalDivider(),
  //           _buildStatItem(
  //             icon: Iconsax.arrow_down_2,
  //             value: '₡65,430',
  //             label: 'Gastos',
  //             color: const Color(0xFFFF6B6B),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 40,
      color:
          isDark
              ? const Color(0xFF334155).withOpacity(0.5)
              : const Color(0xFFE5E7EB),
    );
  }

  Widget _buildPersonalInfoSection(AppUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
          // Header de la sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Iconsax.profile_circle,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF2D5BFF),
                ),
                const SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showPlaceholderDialog('Editar Perfil'),
                  icon: Icon(
                    Iconsax.edit_2,
                    size: 18,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Información del usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Iconsax.user,
                  label: 'Username',
                  value: user.username,
                  color: const Color(0xFF2D5BFF),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Iconsax.call,
                  label: 'Teléfono',
                  value: user.phoneNumber,
                  color: const Color(0xFF00C896),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Iconsax.calendar,
                  label: 'Miembro desde',
                  value: 'Enero 2024', // Esto debería venir del usuario
                  color: const Color(0xFFFFA726),
                ),
              ],
            ),
          ),

          // Botón de verificación
          if (true) // Cambiar a true cuando implementes verificación
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => _showPlaceholderDialog('Verificación'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.verify,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verificación de identidad',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Tu cuenta está verificada',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.arrow_right_3,
                        size: 18,
                        color: Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue = value.isEmpty ? 'No especificado' : value;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialMetrics() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Métricas Financieras',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Presupuesto',
                value: '₡80,000',
                subtitle: 'Disponible',
                icon: Iconsax.wallet_money,
                color: const Color(0xFF2D5BFF),
                progress: 0.65,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Ahorros',
                value: '₡25,430',
                subtitle: 'Este mes',
                icon: Iconsax.chart_2,
                color: const Color(0xFF00C896),
                progress: 0.85,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.profile_remove,
              size: 64,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              'No autenticado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Por favor inicia sesión para ver tu perfil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
