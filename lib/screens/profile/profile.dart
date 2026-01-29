import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_event.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_state.dart';
import 'package:walleta/screens/profile/personalExpense/expense_card.dart';
import 'package:walleta/screens/profile/personalExpense/expense_list.dart';
import 'package:walleta/screens/profile/personalExpense/personal_expense.dart';
import 'package:walleta/screens/profile/personal_info.dart';
import 'package:walleta/screens/savings/savings_account.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/cards/savings_card.dart';
import 'package:walleta/widgets/layaout/appbar/drawer/custom_drawer.dart';
import 'package:walleta/blocs/saving/bloc/saving_bloc.dart';
import 'package:walleta/blocs/saving/bloc/saving_state.dart';
import 'package:walleta/blocs/saving/bloc/saving_event.dart';

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
    _loadExpenses();
    _loadSavings();
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

  void _loadExpenses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthenticationBloc>().state;
      if (authState.status == AuthenticationStatus.authenticated) {
        context.read<PersonalExpenseBloc>().add(
          LoadPersonalExpenses(authState.user.uid),
        );
      }
    });
  }

  void _loadSavings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthenticationBloc>().state;
      if (authState.status == AuthenticationStatus.authenticated) {
        context.read<SavingBloc>().add(LoadSavingGoals(authState.user.uid));
      }
    });
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

    final authState = context.read<AuthenticationBloc>().state;

    if (authState.status != AuthenticationStatus.authenticated) {
      return;
    }

    final user = authState.user;

    switch (item) {
      case 'personalInfo':
        showProfileFloatingWidget(context, user);
        break;
      case 'notifications':
        _showPlaceholderDialog('Notificaciones');
        break;
      case 'verify':
        _showPlaceholderDialog('Verificar identidad');
        break;
      case 'reports':
        _showPlaceholderDialog('Reportes');
        break;
      case 'help':
        _showPlaceholderDialog('Invitar Amigos');
        break;
      case 'invite':
        _showPlaceholderDialog('invite');
        break;
      case 'logout':
        context.read<AuthenticationBloc>().add(AuthenticationLogoutRequested());
        break;
    }
  }

  void _showPlaceholderDialog(String feature) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Iconsax.clock,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            feature,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Próximamente',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Esta función está en desarrollo y estará disponible en una futura actualización.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Mantente atento!',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(
                          'Entendido',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _openSavingsScreen(BuildContext context, String userId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SavingsAccountScreen(userId: userId),
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
  void _openSavingsScreenWithHeroAnimation(
    BuildContext context,
    String userId,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                SavingsAccountScreen(userId: userId),
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

  void _openExpensesListScreen(String userId) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PersonalExpensesListScreen(userId: userId),
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

  void _showAddPersonalExpenseSheet(String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PersonalExpenseSheet(userId: userId),
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
                automaticallyImplyLeading: false,
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
              SliverToBoxAdapter(child: const SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: BlocBuilder<SavingBloc, SavingState>(
                    builder: (context, state) {
                      if (state.status == SavingStateStatus.success &&
                          state.goals.isNotEmpty) {
                        final totalSaved = state.goals.fold(
                          0.0,
                          (sum, goal) => sum + goal.saved,
                        );

                        final totalGoal = state.goals.fold(
                          0.0,
                          (sum, goal) => sum + goal.goal,
                        );

                        return SavingsCard(
                          onTap:
                              () => _openSavingsScreenWithHeroAnimation(
                                context,
                                user.uid,
                              ),
                          currentSavings: totalSaved,
                          monthlyGoal: totalGoal,
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: _buildPersonalExpensesCard(user.uid),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPersonalExpensesCard(String userId) {
    return BlocBuilder<PersonalExpenseBloc, PersonalExpenseState>(
      builder: (context, state) {
        // Calcular totales
        final totalExpenses = state.expenses.fold(
          0.0,
          (sum, expense) => sum + expense.total,
        );
        final totalPaid = state.expenses.fold(
          0.0,
          (sum, expense) => sum + expense.paid,
        );
        final totalPending = totalExpenses - totalPaid;
        final progress = totalExpenses > 0 ? totalPaid / totalExpenses : 0.0;

        return PersonalExpensesCard(
          onTap: () => _openExpensesListScreen(userId),
          totalExpenses: totalExpenses,
          totalPaid: totalPaid,
          totalPending: totalPending,
          progress: progress,
          expenseCount: state.expenses.length,
        );
      },
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
