import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/category_data.dart';
import 'package:walleta/providers/auth_provider.dart';
import 'package:walleta/screens/dashboard/loans_section.dart';
import 'package:walleta/widgets/buttons/search_button.dart';

class FinancialDashboard extends StatefulWidget {
  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  // Datos de ejemplo
  final double currentBalance = 125430.50;
  final double monthlyExpenses = 0;
  final double monthlyIncome = 150000.00;
  final double changeVsPrevious = 0; // porcentaje

  final List<CategoryData> categoryData = [
    CategoryData('Comida', 25000, const Color(0xFF2D5BFF), Icons.restaurant),
    CategoryData(
      'Viajes',
      25000,
      const Color(0xFF9C27B0),
      Icons.airplanemode_active,
    ),
    CategoryData(
      'Entretenimiento',
      8000,
      const Color(0xFFFFA726),
      Icons.sports_esports,
    ),

    CategoryData('Hogar', 12000, const Color(0xFFFF6B6B), Icons.home),
    CategoryData(
      'Transporte',
      18000,
      const Color(0xFF00C896),
      Icons.directions_car,
    ),

    CategoryData('Otros', 3000, const Color(0xFF9CA3AF), Icons.more_horiz),
  ];

  final List<SharedExpense> sharedExpenses = [
    SharedExpense('Cena con Ana', 5000, true, 'Ana', Icons.person),
    SharedExpense('Renta', 20000, false, 'Carlos', Icons.person),
    SharedExpense('Supermercado', 7500, true, 'Luisa', Icons.person),
    SharedExpense('Gasolina', 3000, false, 'Pedro', Icons.person),
  ];

  // double get totalSharedExpenses =>
  //     sharedExpenses.fold(0, (sum, item) => sum + item.amount);
  // double get totalOwe => sharedExpenses
  //     .where((e) => e.isOwed)
  //     .fold(0, (sum, item) => sum + item.amount);
  // double get totalOwed => sharedExpenses
  //     .where((e) => !e.isOwed)
  //     .fold(0, (sum, item) => sum + item.amount);

  // @override
  // void initState() {
  //   super.initState();
  //   //!Esto es para que cuando se carga el widget vaya pidiendo datos
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final authState = context.read<AuthenticationBloc>().state;

  //     if (authState.status == AuthenticationStatus.authenticated) {
  //       final user = authState.user;
  //       print(user);

  //       // context.read<ClientPostBloc>().add(LoadUserClientPosts(user: user));
  //     }
  //   });
  // }

  bool _isSearchActive = false;

  void _onSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchActive = isActive;
    });
  }

  String _formatCurrency(double amount) {
    return '₡${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;

    print("Usuario en dashboard: ${user}");

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D1F);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido,',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user.name} ${user.surname}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SearchButton(
                          onSearchStateChanged: _onSearchStateChanged,
                        ),
                        const SizedBox(width: 5),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: child,
                              ),
                            );
                          },
                          child:
                              _isSearchActive
                                  ? const SizedBox(width: 0, height: 48)
                                  : Container(
                                    key: const ValueKey('notification'),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(
                                      Iconsax.notification,
                                      size: 24,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sección 1: Resumen Rápido
                Text(
                  'Resumen Financiero',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Grid de métricas
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildMetricCard(
                      title: 'Gastos del Mes',
                      amount: 0,
                      icon: Iconsax.arrow_down_2,
                      color: const Color(0xFFFF6B6B),
                      cardColor: cardColor,
                      isExpense: true,
                    ),
                    _buildChangeCard(cardColor, textColor),
                  ],
                ),
                const SizedBox(height: 32),

                // Sección 2: Gráfico de Gastos
                Text(
                  'Gastos por Categoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildChartSection(cardColor, textColor),
                const SizedBox(height: 32),

                // Sección 3: Gastos Compartidos
                Text(
                  'Prestamos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                LoansSection(cardColor: cardColor, textColor: textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color cardColor,
    bool isExpense = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isExpense)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '-${_formatCurrency(monthlyExpenses)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(amount),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCard(Color cardColor, Color textColor) {
    bool isPositive = changeVsPrevious >= 0;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? const Color(0xFF00C896).withOpacity(0.1)
                          : const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  isPositive ? Iconsax.trend_up : Iconsax.trend_down,
                  color:
                      isPositive
                          ? const Color(0xFF00C896)
                          : const Color(0xFFFF6B6B),
                  size: 20,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? const Color(0xFF00C896).withOpacity(0.1)
                          : const Color(0xFFFF6B6B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down_1,
                      size: 12,
                      color:
                          isPositive
                              ? const Color(0xFF00C896)
                              : const Color(0xFFFF6B6B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changeVsPrevious.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color:
                            isPositive
                                ? const Color(0xFF00C896)
                                : const Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cambio vs mes anterior',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                isPositive ? 'Aumento positivo' : 'Disminución',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Color cardColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<CategoryData, String>(
                  dataSource: categoryData,
                  xValueMapper: (CategoryData data, _) => data.name,
                  yValueMapper: (CategoryData data, _) => data.amount,
                  pointColorMapper: (CategoryData data, _) => data.color,
                  innerRadius: '70%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children:
                categoryData.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(category.icon, color: category.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                        Text(
                          _formatCurrency(category.amount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
