import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/screens/loans/empty_loan.dart';
import 'package:walleta/screens/loans/filter_option.dart';
import 'package:walleta/screens/loans/form/add_loan.dart';
import 'package:walleta/screens/loans/loan_card.dart';
import 'package:walleta/widgets/toggle/loan_tab_button.dart';

class Loans extends StatefulWidget {
  const Loans({super.key});

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {
  int _selectedTab = 0; // 0: Me deben, 1: Debo
  final PageController _pageController = PageController();

  final ScrollController _scrollController = ScrollController();

  final List<LoanData> _owedToMe = [
    LoanData(
      name: 'Ana López',
      description: 'Compra de libros',
      amount: 15000,
      date: '25 Oct 2026',
      status: 'Pendiente',
      progress: 0.4,
      color: const Color(0xFF00C896),
    ),
    LoanData(
      name: 'Carlos Méndez',
      description: 'Gasolina',
      amount: 8000,
      date: '30 Oct 2026',
      status: 'Pendiente',
      progress: 0.7,
      color: const Color(0xFF2D5BFF),
    ),
    LoanData(
      name: 'María Rodríguez',
      description: 'Mesa',
      amount: 12000,
      date: '15 Nov 2026',
      status: 'Pendiente',
      progress: 0.2,
      color: const Color(0xFFFFA726),
    ),
  ];

  final List<LoanData> _iOwe = [
    LoanData(
      name: 'Pedro Sánchez',
      description: 'Renta compartida',
      amount: 25000,
      date: '20 Oct 2026',
      status: 'Atrasado',
      progress: 0.6,
      color: const Color(0xFFFF6B6B),
    ),
    LoanData(
      name: 'Luisa Fernández',
      description: 'Materiales oficina',
      amount: 15000,
      date: '28 Oct 2026',
      status: 'Por vencer',
      progress: 0.3,
      color: const Color(0xFFFFA726),
    ),
  ];

  double get totalOwedToMe =>
      _owedToMe.fold(0, (sum, item) => sum + item.amount);

  double get totalIOwe => _iOwe.fold(0, (sum, item) => sum + item.amount);

  double get netBalance => totalOwedToMe - totalIOwe;

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Iconsax.add, color: iconsColor, size: 24),
                    onPressed: () {
                      _showAddLoanDialog(isDark);
                    },
                  ),
                  IconButton(
                    icon: Icon(Iconsax.filter, color: iconsColor, size: 24),
                    onPressed: () => _showFilterDialog(isDark),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // _buildHeaderStats(isDark),
                    _buildTabDrawer(isDark, screenWidth),
                  ],
                ),
              ),
            ];
          },
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _selectedTab = index);
            },
            children: [
              _buildLoansList(_owedToMe, 'Te deben', isDark),
              _buildLoansList(_iOwe, 'Debes', isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildHeaderStats(bool isDark) {
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
  //               '₡${netBalance.toInt()}',
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

  // Widget _buildStatChip({
  //   required String label,
  //   required double amount,
  //   required Color color,
  //   required bool isDark,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: color.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: color.withOpacity(0.3), width: 0.5),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: color,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const SizedBox(height: 2),
  //         Text(
  //           '₡${amount.toInt()}',
  //           style: TextStyle(
  //             fontSize: 14,
  //             fontWeight: FontWeight.w700,
  //             color: isDark ? Colors.white : const Color(0xFF1F2937),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  Widget _buildLoansList(List<LoanData> loans, String title, bool isDark) {
    if (loans.isEmpty) {
      return EmptyLoanState(
        onAddLoanPressed: () => _showAddLoanDialog(isDark),
        title: title,
        isDark: isDark,
        selectedTab: _selectedTab,
      );
    }

    return Column(
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
                '₡${loans.fold(0.0, (sum, item) => sum + item.amount).toInt()}',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              return LoanCard(
                loan: loans[index],
                isDark: isDark,
                selectedTab: _selectedTab,
                iOwe: _iOwe,
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddLoanDialog(bool isDark) {
    // Resetear campos
    // _selectedUser = null;
    // _personController.clear();
    // _amountController.clear();
    // _descriptionController.clear();
    // _selectedDate = null;

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

                        iOwe: [..._iOwe],
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
