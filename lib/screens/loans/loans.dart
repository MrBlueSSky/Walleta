import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/widgets/buttons/search_button.dart';

class Loans extends StatefulWidget {
  const Loans({super.key});

  @override
  State<Loans> createState() => _LoansState();
}

class _LoansState extends State<Loans> {
  int _selectedTab = 0; // 0: Me deben, 1: Debo
  final PageController _pageController = PageController();
  AppUser? _selectedUser;
  TextEditingController _personController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Yo debo';
  DateTime? _selectedDate;

  final ScrollController _scrollController = ScrollController();

  final List<LoanData> _owedToMe = [
    LoanData(
      name: 'Ana López',
      description: 'Compra de libros',
      amount: 15000,
      date: '25 Oct 2024',
      status: 'Pendiente',
      progress: 0.4,
      color: const Color(0xFF00C896),
    ),
    LoanData(
      name: 'Carlos Méndez',
      description: 'Gasolina',
      amount: 8000,
      date: '30 Oct 2024',
      status: 'Pendiente',
      progress: 0.7,
      color: const Color(0xFF2D5BFF),
    ),
    LoanData(
      name: 'María Rodríguez',
      description: 'Mesa',
      amount: 12000,
      date: '15 Nov 2024',
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
      date: '20 Oct 2024',
      status: 'Atrasado',
      progress: 0.6,
      color: const Color(0xFFFF6B6B),
    ),
    LoanData(
      name: 'Luisa Fernández',
      description: 'Materiales oficina',
      amount: 15000,
      date: '28 Oct 2024',
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
    _personController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
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

  Widget _buildHeaderStats(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance Neto',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₡${netBalance.toInt()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color:
                      netBalance >= 0
                          ? const Color(0xFF00C896)
                          : const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildStatChip(
                label: 'Te deben',
                amount: totalOwedToMe,
                color: const Color(0xFF00C896),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                label: 'Debes',
                amount: totalIOwe,
                color: const Color(0xFFFF6B6B),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            '₡${amount.toInt()}',
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
          _buildTabButton(
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
          _buildTabButton(
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

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDark
                        ? const Color(0xFF2D5BFF)
                        : const Color(0xFF2D5BFF))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
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

  Widget _buildLoansList(List<LoanData> loans, String title, bool isDark) {
    if (loans.isEmpty) {
      return _buildEmptyState(title, isDark);
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
              return _buildLoanCard(loans[index], isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoanCard(LoanData loan, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showLoanDetails(loan, isDark),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: loan.color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              loan.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: loan.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loan.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              loan.description,
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
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: loan.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: loan.color.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        loan.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: loan.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₡${loan.amount.toInt()}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Monto total',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          loan.date,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'Vence',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Aumentado de 12 a 16
                // BARRA DE PROGRESO ANIMADA
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutQuart,
                  tween: Tween<double>(begin: 0.0, end: loan.progress),
                  builder: (context, value, child) {
                    return Container(
                      height: 8, // Aumentado de 6 a 8
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF3F4F6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Fondo
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFF3F4F6),
                            ),
                          ),
                          // Barra de progreso animada
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: [
                                    loan.color,
                                    Color.lerp(loan.color, Colors.white, 0.2)!,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: loan.color.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Efecto de brillo
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.3],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.money_send, size: 14, color: loan.color),
                        const SizedBox(width: 6),
                        // Porcentaje animado también
                        TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutQuart,
                          tween: IntTween(
                            begin: 0,
                            end: (loan.progress * 100).toInt(),
                          ),
                          builder: (context, value, child) {
                            return Text(
                              '$value% pagado',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark
                                        ? Colors.white70
                                        : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (_selectedTab == 1)
                      TextButton(
                        onPressed:
                            () => _showRegisterPaymentDialog(loan, isDark),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.add_circle,
                              size: 14,
                              color: loan.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Registrar pago',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: loan.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                title == 'Te deben' ? Iconsax.people : Iconsax.profile_2user,
                size: 48,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay registros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando tengas $title, aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showAddLoanDialog(isDark),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.add, size: 18),
                  SizedBox(width: 8),
                  Text('Agregar nuevo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLoanDialog(bool isDark) {
    // Resetear campos
    _selectedUser = null;
    _personController.clear();
    _amountController.clear();
    _descriptionController.clear();
    _selectedType = 'Yo debo';
    _selectedDate = null;

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
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildAddLoanForm(isDark, scrollController),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddLoanForm(bool isDark, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Nuevo Préstamo/Deuda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),

          // Campo de persona con buscador
          _buildPersonSearchField(isDark),
          const SizedBox(height: 20),

          // Campo de monto
          Text(
            'Monto',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark
                        ? const Color(0xFF334155).withOpacity(0.3)
                        : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        fontSize: 16,
                        height: 1.2, // Ajusta la altura del texto
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color:
                              isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                          fontSize: 16,
                          height: 1.2,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ), // Ajuste importante
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Iconsax.money,
                            size: 20,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        isDense: true, // Hace que el campo sea menos alto
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '₡',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campo de descripción
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark
                        ? const Color(0xFF334155).withOpacity(0.3)
                        : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _descriptionController,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 16,
                  height: 1.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej: Préstamo para...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                    fontSize: 16,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // Ajuste
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 0, right: 8),
                    child: Icon(
                      Iconsax.note,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                maxLines: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Campo de fecha
          Text(
            'Fecha límite',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDate(isDark),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF334155).withOpacity(0.3)
                          : const Color(0xFFE5E7EB),
                  width: 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Iconsax.calendar,
                      size: 20,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Seleccionar fecha límite',
                      style: TextStyle(
                        color:
                            _selectedDate != null
                                ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937))
                                : (isDark
                                    ? Colors.white60
                                    : const Color(0xFF9CA3AF)),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    IconButton(
                      icon: const Icon(Iconsax.close_circle, size: 18),
                      color: const Color(0xFF6B7280),
                      onPressed: () {
                        setState(() {
                          _selectedDate = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón de guardar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_validateForm()) {
                  _saveLoan();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Guardar Préstamo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPersonSearchField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Persona',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: SearchButton(
                size: 22,
                onUserSelected: (user) {
                  setState(() {
                    _selectedUser = AppUser(
                      name: user['name'] ?? '',
                      surname: user['surname'] ?? '',
                      email: user['email'] ?? '',
                      username: user['username'] ?? '',
                      profilePictureUrl: user['profilePictureUrl'] ?? '',
                      uid: user['uid'] ?? '',
                      phoneNumber: user['phoneNumber'] ?? '',
                    );
                    _personController.text =
                        '${user['name']} ${user['surname']}';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark
                      ? const Color(0xFF334155).withOpacity(0.3)
                      : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _personController,
                    readOnly: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 16,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar persona...',
                      hintStyle: TextStyle(
                        color:
                            isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                        fontSize: 16,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          Iconsax.user,
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      suffixIcon:
                          _personController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Iconsax.close_circle,
                                  size: 18,
                                ),
                                color: const Color(0xFF6B7280),
                                onPressed: () {
                                  _personController.clear();
                                  setState(() {
                                    _selectedUser = null;
                                  });
                                },
                              )
                              : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Mostrar información del usuario seleccionado
        if (_selectedUser != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        _selectedUser!.profilePictureUrl.isNotEmpty
                            ? null
                            : const LinearGradient(
                              colors: [Color(0xFF2D5BFF), Color(0xFF00C896)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                  ),
                  child:
                      _selectedUser!.profilePictureUrl.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              _selectedUser!.profilePictureUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Center(
                            child: Text(
                              _selectedUser!.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${_selectedUser!.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                    // Text(
                    //   _selectedUser!.email,
                    //   style: TextStyle(
                    //     fontSize: 11,
                    //     color:
                    //         isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _validateForm() {
    if (_selectedUser == null || _personController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecciona una persona'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, ingresa un monto válido'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecciona una fecha límite'),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }

    return true;
  }

  void _saveLoan() {
    // Aquí iría la lógica para guardar el préstamo en tu backend
    final newLoan = LoanData(
      name: _selectedUser!.name,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Préstamo',
      amount: double.parse(_amountController.text),
      date:
          '${_selectedDate!.day} ${_getMonthName(_selectedDate!.month)} ${_selectedDate!.year}',
      status: 'Pendiente',
      progress: 0.0,
      color:
          _selectedType == 'Yo debo'
              ? const Color(0xFFFF6B6B)
              : const Color(0xFF00C896),
    );

    if (_selectedType == 'Yo debo') {
      _iOwe.add(newLoan);
    } else {
      _owedToMe.add(newLoan);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Préstamo agregado a $_selectedType'),
        backgroundColor: const Color(0xFF00C896),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month - 1];
  }

  void _showFilterDialog(bool isDark) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                _buildFilterOption('Todos', isDark),
                _buildFilterOption('Pendientes', isDark),
                _buildFilterOption('Parciales', isDark),
                _buildFilterOption('Atrasados', isDark),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
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
          ),
    );
  }

  Widget _buildFilterOption(String option, bool isDark) {
    bool isSelected = false;

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isSelected
                          ? const Color(0xFF2D5BFF)
                          : (isDark ? Colors.white30 : const Color(0xFFE5E7EB)),
                  width: isSelected ? 6 : 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle,
                size: 20,
                color: const Color(0xFF2D5BFF),
              ),
          ],
        ),
      ),
    );
  }

  void _showLoanDetails(LoanData loan, bool isDark) {
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
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildLoanDetailsContent(
                    loan,
                    isDark,
                    scrollController,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoanDetailsContent(
    LoanData loan,
    bool isDark,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white30 : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: loan.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    loan.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: loan.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      loan.description,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  'Monto total',
                  '₡${loan.amount.toInt()}',
                  isDark,
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Fecha límite', loan.date, isDark),
                const SizedBox(height: 12),
                _buildDetailRow('Estado', loan.status, isDark),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Progreso',
                  '${(loan.progress * 100).toInt()}%',
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  width: double.infinity * loan.progress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [loan.color, loan.color.withOpacity(0.8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: loan.color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Editar',
                    style: TextStyle(
                      color: loan.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showRegisterPaymentDialog(loan, isDark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loan.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Registrar pago',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  void _showRegisterPaymentDialog(LoanData loan, bool isDark) {
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
              initialChildSize: 0.5,
              minChildSize: 0.4,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.white30
                                      : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Text(
                          'Registrar Pago',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loan.name,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Saldo pendiente: ₡${(loan.amount * (1 - loan.progress)).toInt()}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isDark
                                      ? const Color(0xFF334155).withOpacity(0.3)
                                      : const Color(0xFFE5E7EB),
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                fontSize: 16,
                                height: 1.2, // ← Añade esta línea
                              ),
                              decoration: InputDecoration(
                                hintText: 'Monto del pago',
                                hintStyle: TextStyle(
                                  color:
                                      isDark
                                          ? Colors.white60
                                          : const Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  height: 1.2, // ← Añade esta línea
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ), // ← Añade esta línea
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 8,
                                  ), // ← Ajusta el padding del icono
                                  child: Icon(
                                    Iconsax.money,
                                    size: 20,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                                isDense:
                                    true, // ← Opcional: hace el campo menos alto
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Confirmar pago',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _pickDate(bool isDark) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF2D5BFF),
              onPrimary: Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            dialogBackgroundColor:
                isDark ? const Color(0xFF1E293B) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
}

class LoanData {
  final String name;
  final String description;
  final double amount;
  final String date;
  final String status;
  final double progress;
  final Color color;

  LoanData({
    required this.name,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.progress,
    required this.color,
  });
}
