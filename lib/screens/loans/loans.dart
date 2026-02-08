import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_event.dart';
import 'package:walleta/blocs/loan/bloc/loan_state.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/screens/loans/empty_loan.dart';
import 'package:walleta/screens/loans/filter_option.dart';
import 'package:walleta/screens/loans/form/add_loan.dart';
import 'package:walleta/screens/loans/loan_card.dart';
import 'package:walleta/widgets/common/trash_overlay.dart';
import 'package:walleta/widgets/toggle/loan_tab_button.dart';
import 'package:walleta/utils/formatters.dart'; // ← AGREGAR ESTA LÍNEA

class Loans extends StatefulWidget {
  const Loans({super.key});

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {
  int _selectedTab = 0; // 0: Me deben, 1: Debo
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  // En la clase _LoansState
  final TrashOverlayController _trashController = TrashOverlayController();

  @override
  void initState() {
    super.initState();

    // Cargar préstamos después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialLoans();
    });
  }

  void _loadInitialLoans() {
    // Obtener el estado actual de autenticación
    final authBloc = context.read<AuthenticationBloc>();
    final authState = authBloc.state;

    // Si el usuario ya está autenticado, cargar sus préstamos
    if (authState.status == AuthenticationStatus.authenticated) {
      final userId = authState.user!.uid;
      print('🚀 Cargando préstamos iniciales para usuario: $userId');
      context.read<LoanBloc>().add(LoadLoans(userId));
    }
  }

  // Función para recargar datos
  Future<void> _refreshLoans() async {
    final authBloc = context.read<AuthenticationBloc>();
    final authState = authBloc.state;

    if (authState.status == AuthenticationStatus.authenticated) {
      final userId = authState.user!.uid;
      print('🔄 Recargando préstamos para usuario: $userId');
      context.read<LoanBloc>().add(LoadLoans(userId));

      // Esperar un momento para que se complete la carga
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _trashController.hideOverlay(); // Añadir
    super.dispose();
  }

  void _updateDragState(bool isDragging) {
    if (isDragging) {
      _trashController.showOverlay(context);
    } else {
      _trashController.hideOverlay();
    }
  }

  // Filtrar préstamos según la pestaña seleccionada
  List<Loan> _getFilteredLoans(List<Loan> allLoans, String currentUserId) {
    return allLoans.where((loan) {
      if (_selectedTab == 0) {
        // "Me deben" - Soy el prestamista
        return loan.lenderUserId.uid == currentUserId;
      } else {
        // "Yo debo" - Soy el prestatario
        return loan.borrowerUserId.uid == currentUserId;
      }
    }).toList();
  }

  // Calcular totales
  double _calculateTotalOwedToMe(List<Loan> allLoans, String currentUserId) {
    return allLoans
        .where((loan) => loan.lenderUserId.uid == currentUserId)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double _calculateTotalIOwe(List<Loan> allLoans, String currentUserId) {
    return allLoans
        .where((loan) => loan.borrowerUserId.uid == currentUserId)
        .fold(0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    Color iconsColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : const Color(0xFFF8FAFD);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, authState) {
            // Cuando el usuario se autentica o cambia, cargar sus préstamos
            if (authState.status == AuthenticationStatus.authenticated) {
              final userId = authState.user!.uid;
              context.read<LoanBloc>().add(LoadLoans(userId));
            }
          },
        ),
      ],
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          // Si el usuario no está autenticado, mostrar vista no autenticada
          if (authState.status == AuthenticationStatus.unauthenticated) {
            return _buildUnauthenticatedView(isDark);
          }

          final currentUser = authState.user!;
          final currentUserId = currentUser.uid;

          return BlocConsumer<LoanBloc, LoanState>(
            listener: (context, state) {
              if (state.status == LoanStateStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Error al cargar préstamos'),
                    backgroundColor: const Color(0xFFFF6B6B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state.status == LoanStateStatus.loading;
              final hasError = state.status == LoanStateStatus.error;
              final loans = state.loans;

              final filteredLoans = _getFilteredLoans(loans, currentUserId);
              final totalOwedToMe = _calculateTotalOwedToMe(
                loans,
                currentUserId,
              );
              final totalIOwe = _calculateTotalIOwe(loans, currentUserId);
              final netBalance = totalOwedToMe - totalIOwe;

              return Scaffold(
                backgroundColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
                body: SafeArea(
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          floating: true,
                          pinned: true,
                          backgroundColor: backgroundColor,
                          elevation: 0,
                          title: Text(
                            'Deudas y Préstamos',
                            style: TextStyle(
                              color:
                                  isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(
                                Iconsax.add,
                                color: iconsColor,
                                size: 24,
                              ),
                              onPressed: () {
                                _showAddLoanDialog(isDark, currentUser);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Iconsax.filter,
                                color: iconsColor,
                                size: 24,
                              ),
                              onPressed: () => _showFilterDialog(isDark),
                            ),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // _buildHeaderStats(
                              //   isDark,
                              //   netBalance,
                              //   totalOwedToMe,
                              //   totalIOwe,
                              // ),
                              _buildTabDrawer(isDark, screenWidth),
                            ],
                          ),
                        ),
                      ];
                    },
                    body:
                        isLoading
                            ? _buildLoadingState(isDark)
                            : hasError
                            ? _buildErrorState(isDark, currentUserId)
                            : _buildContent(
                              isDark,
                              filteredLoans,
                              loans,
                              currentUserId,
                            ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView(bool isDark) {
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.user_remove,
              size: 64,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(
              'Inicia sesión para ver tus préstamos',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildHeaderStats(
  //   bool isDark,
  //   double netBalance,
  //   double totalOwedToMe,
  //   double totalIOwe,
  // ) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //     decoration: BoxDecoration(
  //       color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
  //       border: Border(
  //         bottom: BorderSide(
  //           color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
  //           width: 0.5,
  //         ),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               'Balance Neto',
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 color: isDark ? Colors.white70 : const Color(0xFF6B7280),
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               Formatters.formatCurrencyNoDecimals(netBalance), // ← CAMBIAR ESTA LÍNEA
  //               style: TextStyle(
  //                 fontSize: 24,
  //                 fontWeight: FontWeight.w700,
  //                 color:
  //                     netBalance >= 0
  //                         ? const Color(0xFF00C896)
  //                         : const Color(0xFFFF6B6B),
  //               ),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             _buildStatChip(
  //               label: 'Te deben',
  //               amount: totalOwedToMe,
  //               color: const Color(0xFF00C896),
  //               isDark: isDark,
  //             ),
  //             const SizedBox(width: 12),
  //             _buildStatChip(
  //               label: 'Debes',
  //               amount: totalIOwe,
  //               color: const Color(0xFFFF6B6B),
  //               isDark: isDark,
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatChip({
    required String label,
    required double amount,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.formatCurrencyNoDecimals(amount), // ← CAMBIAR ESTA LÍNEA
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabDrawer(bool isDark, double screenWidth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Row(
        children: [
          LoanTabButton(
            label: 'Me deben',
            isSelected: _selectedTab == 0,
            isDark: isDark,
            onTap: () {
              setState(() => _selectedTab = 0);
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          LoanTabButton(
            label: 'Yo debo',
            isSelected: _selectedTab == 1,
            isDark: isDark,
            onTap: () {
              setState(() => _selectedTab = 1);
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    bool isDark,
    List<Loan> filteredLoans,
    List<Loan> allLoans,
    String currentUserId,
  ) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => _selectedTab = index);
      },
      children: [
        _buildLoansListWithRefresh(
          filteredLoans,
          'Te deben',
          isDark,
          allLoans,
          currentUserId,
        ),
        _buildLoansListWithRefresh(
          filteredLoans,
          'Debes',
          isDark,
          allLoans,
          currentUserId,
        ),
      ],
    );
  }

  Widget _buildLoansListWithRefresh(
    List<Loan> loans,
    String title,
    bool isDark,
    List<Loan> allLoans,
    String currentUserId,
  ) {
    if (loans.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshLoans,
        color: isDark ? Colors.white : Theme.of(context).primaryColor,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        child: EmptyLoanState(
          onAddLoanPressed: () => _showAddLoanDialog(isDark, null),
          title: title,
          isDark: isDark,
          selectedTab: _selectedTab,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshLoans,
      color: isDark ? Colors.white : const Color(0xFF2D5BFF),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${loans.length} ${title.toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.formatCurrencyNoDecimals(
                    loans.fold(0.0, (sum, item) => sum + item.amount),
                  ), // ← CAMBIAR ESTA LÍNEA
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                return LoanCard(
                  loan: loans[index],
                  isDark: isDark,
                  selectedTab: _selectedTab,
                  iOwe:
                      allLoans
                          .where(
                            (loan) => loan.borrowerUserId.uid == currentUserId,
                          )
                          .toList(),
                  onDragStateChanged:
                      _selectedTab == 0
                          ? _updateDragState
                          : null, // Solo para "Me deben"
                  canDelete:
                      _selectedTab == 0, // Solo se puede eliminar en "Me deben"
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? Colors.white : const Color(0xFF2D5BFF),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando préstamos...',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String currentUserId) {
    return RefreshIndicator(
      onRefresh: _refreshLoans,
      color: isDark ? Colors.white : const Color(0xFF2D5BFF),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.warning_2,
                  size: 48,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar préstamos',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Intenta de nuevo más tarde',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<LoanBloc>().add(LoadLoans(currentUserId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D5BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reintentar'),
                ),
                const SizedBox(height: 8),
                Text(
                  'o desliza hacia abajo para recargar',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddLoanDialog(bool isDark, currentUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            child: DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (context, setDialogState) {
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: AddLoanForm(
                        context: context,
                        isDark: isDark,
                        scrollController: scrollController,
                        setDialogState: setDialogState,
                        iOwe: [], // Ya no necesitamos pasar esta lista
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(bool isDark) {
    bool allSelected = true;
    bool pendingSelected = false;
    bool partialSelected = false;
    bool overdueSelected = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor:
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Filtrar',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilterOption(
                      option: 'Todos',
                      isSelected: allSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          allSelected = !allSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Pendientes',
                      isSelected: pendingSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          pendingSelected = !pendingSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Parciales',
                      isSelected: partialSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          partialSelected = !partialSelected;
                        });
                      },
                    ),
                    FilterOption(
                      option: 'Atrasados',
                      isSelected: overdueSelected,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          overdueSelected = !overdueSelected;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D5BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Aplicar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
