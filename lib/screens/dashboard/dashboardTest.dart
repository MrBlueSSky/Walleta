import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_event.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_state.dart';
import 'package:walleta/models/financial_summary.dart';

import 'package:walleta/screens/dashboard/loans_section.dart';
import 'package:walleta/widgets/buttons/search_button.dart';

class FinancialDashboard extends StatefulWidget {
  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  final double monthlyIncome = 150000.00;
  double changeVsPrevious = 0; // porcentaje

  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthenticationBloc>().state.user;
      context.read<FinancialSummaryBloc>().add(LoadFinancialSummary(user.uid));
    });
  }

  void _onSearchStateChanged(bool isActive) {
    setState(() {
      _isSearchActive = isActive;
    });
  }

  String _formatCurrencyNoDecimals(double amount) {
    return '₡${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // Convertir FinancialSummary a CategoryData para el gráfico
  List<CategoryData> _convertToCategoryData(List<FinancialSummary> summaries) {
    return summaries.map((summary) {
      // Mapear categorías a íconos específicos
      IconData getIconForCategory(String category) {
        final iconMap = {
          'compras': Icons.shopping_bag,
          'comida': Icons.restaurant,
          'restaurante': Icons.restaurant,
          'entretenimiento': Icons.sports_esports,
          'hogar': Icons.home,
          'casa': Icons.home,
          'transporte': Icons.directions_car,
          'servicios': Icons.receipt_long,
          'salud': Icons.local_hospital,
          'educación': Icons.school,
          'ropa': Icons.checkroom,
          'deportes': Icons.sports,
          'viajes': Icons.flight,
          'regalos': Icons.card_giftcard,
          'mascotas': Icons.pets,
        };

        return iconMap[category.toLowerCase()] ?? Icons.category;
      }

      // Mapear categorías a colores específicos
      Color getColorForCategory(String category) {
        final colorMap = {
          'compras': const Color(0xFF2D5BFF),
          'comida': const Color(0xFF10B981),
          'restaurante': const Color(0xFF10B981),
          'entretenimiento': const Color(0xFF8B5CF6),
          'hogar': const Color(0xFFEC4899),
          'casa': const Color(0xFFEC4899),
          'transporte': const Color(0xFFF59E0B),
          'servicios': const Color(0xFF14B8A6),
          'salud': const Color(0xFFEF4444),
          'educación': const Color(0xFF3B82F6),
          'ropa': const Color(0xFF8B5CF6),
          'deportes': const Color(0xFF10B981),
          'viajes': const Color(0xFFF59E0B),
          'regalos': const Color(0xFFEC4899),
          'mascotas': const Color(0xFF8B5CF6),
        };

        return colorMap[category.toLowerCase()] ??
            const Color(0xFF9CA3AF); // Gris para otros
      }

      return CategoryData(
        summary.categoryName,
        summary.totalAmount,
        getColorForCategory(summary.category),
        getIconForCategory(summary.category),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el usuario del AuthProvider
    final user = context.read<AuthenticationBloc>().state.user;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D1F);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocConsumer<FinancialSummaryBloc, FinancialSummaryState>(
          listener: (context, state) {
            if (state is FinancialSummaryError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is FinancialSummaryLoading;
            final hasData = state is FinancialSummaryLoaded;
            final hasError = state is FinancialSummaryError;

            // Datos para el gráfico
            List<CategoryData> chartData = [];
            double monthlyExpenses = 0;
            double totalUserPaid = 0;

            if (hasData) {
              final loadedState = state as FinancialSummaryLoaded;
              chartData = _convertToCategoryData(loadedState.summaries);

              // Calcular totales desde los summaries
              monthlyExpenses = loadedState.summaries.fold<double>(
                0,
                (sum, summary) => sum + summary.totalAmount,
              );
              totalUserPaid = loadedState.summaries.fold<double>(
                0,
                (sum, summary) => sum + summary.userPaidAmount,
              );

              // Calcular cambio vs mes anterior
              if (monthlyIncome > 0) {
                changeVsPrevious =
                    ((monthlyIncome - monthlyExpenses) / monthlyIncome) * 100;
              }
            } else if (isLoading) {
              // Datos de carga
              chartData = [
                CategoryData(
                  'Cargando...',
                  10000,
                  Colors.grey[300]!,
                  Icons.hourglass_empty,
                ),
              ];
            } else if (hasError) {
              // Datos de error
              chartData = [
                CategoryData(
                  'Sin datos',
                  10000,
                  Colors.grey[300]!,
                  Icons.error_outline,
                ),
              ];
            } else {
              // Estado inicial
              chartData = [
                CategoryData(
                  'Sin gastos',
                  10000,
                  Colors.grey[300]!,
                  Icons.pie_chart_outline,
                ),
              ];
            }

            return SingleChildScrollView(
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
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
                          amount: monthlyExpenses,
                          icon: Iconsax.arrow_down_2,
                          color: const Color(0xFFFF6B6B),
                          cardColor: cardColor,
                          isExpense: true,
                          isLoading: isLoading,
                        ),
                        _buildChangeCard(
                          cardColor,
                          textColor,
                          changeVsPrevious,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sección 2: Gráfico de Gastos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Gastos por Categoría',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        if (hasData && monthlyExpenses > 0)
                          Text(
                            'Total: ${_formatCurrencyNoDecimals(monthlyExpenses)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildChartSection(
                      cardColor,
                      textColor,
                      chartData,
                      isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Sección 3: Gastos Compartidos
                    Text(
                      'Préstamos',
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
            );
          },
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
    bool isLoading = false,
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
              if (isExpense && !isLoading && amount > 0)
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
                    '-${_formatCurrencyNoDecimals(amount)}',
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
              isLoading
                  ? Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                  : Text(
                    _formatCurrencyNoDecimals(amount),
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

  Widget _buildChangeCard(
    Color cardColor,
    Color textColor,
    double changePercent,
  ) {
    bool isPositive = changePercent >= 0;

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
              if (changePercent != 0)
                Container(
                  decoration: BoxDecoration(
                    color:
                        isPositive
                            ? const Color(0xFF00C896).withOpacity(0.1)
                            : const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                        '${changePercent.abs().toStringAsFixed(1)}%',
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
                isPositive ? 'Ahorro positivo' : 'Gasto mayor',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              if (changePercent == 0)
                Text(
                  'Sin datos previos',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(
    Color cardColor,
    Color textColor,
    List<CategoryData> chartData,
    bool isLoading,
  ) {
    // Calcular total para porcentajes
    final totalAmount = chartData.fold<double>(
      0,
      (sum, category) => sum + category.amount,
    );

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
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                    : chartData.isEmpty || totalAmount == 0
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay gastos registrados',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SfCircularChart(
                      series: <CircularSeries>[
                        DoughnutSeries<CategoryData, String>(
                          dataSource: chartData,
                          xValueMapper: (CategoryData data, _) => data.name,
                          yValueMapper: (CategoryData data, _) => data.amount,
                          pointColorMapper:
                              (CategoryData data, _) => data.color,
                          innerRadius: '70%',
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            connectorLineSettings: ConnectorLineSettings(
                              length: '20',
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 16),
          isLoading
              ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 16,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(height: 16, color: Colors.grey[200]),
                        ),
                        Container(
                          width: 60,
                          height: 16,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  );
                },
              )
              : chartData.isEmpty || totalAmount == 0
              ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.data_array, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Agrega gastos para ver el desglose',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              )
              : Column(
                children:
                    chartData.map((category) {
                      final percentage =
                          totalAmount > 0
                              ? (category.amount / totalAmount * 100)
                              : 0;

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
                            Icon(
                              category.icon,
                              color: category.color,
                              size: 16,
                            ),
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
                              _formatCurrencyNoDecimals(category.amount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: category.color,
                                  fontWeight: FontWeight.w600,
                                ),
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

// Clase auxiliar para mantener compatibilidad
class CategoryData {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  CategoryData(this.name, this.amount, this.color, this.icon);
}
