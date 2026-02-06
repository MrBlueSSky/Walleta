import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_event.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_state.dart';
import 'package:walleta/models/category.dart';
import 'package:walleta/models/financial_summary.dart';

import 'package:walleta/screens/dashboard/loans_section.dart';
import 'package:walleta/utils/formatters.dart';
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

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

  Future<void> _refreshData() async {
    final user = context.read<AuthenticationBloc>().state.user;
    context.read<FinancialSummaryBloc>().add(LoadFinancialSummary(user.uid));
    // Esperar un momento para que la animación se vea bien
    await Future.delayed(const Duration(milliseconds: 800));
  }

  // Método actualizado para quitar .00
  String _formatCurrencyNoDecimals(double amount) {
    return Formatters.formatCurrencyNoDecimals(amount);
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
          'compras': const Color(0xFF2563EB), // Azul real vibrante
          'comida': const Color(0xFF10B981), // Verde esmeralda (mantenido)
          'restaurante': const Color(0xFFF59E0B), // Ámbar cálido
          'entretenimiento': const Color(0xFF7C3AED), // Púrpura elegante
          'hogar': const Color(0xFFDB2777), // Rosa profesional
          'transporte': const Color(0xFF0EA5E9), // Azul cielo (mantenido)
          'servicios': const Color(0xFF0891B2), // Azul turquesa
          'salud': const Color(0xFFDC2626), // Rojo profesional
          'educación': const Color(0xFF4F46E5), // Índigo elegante
          'ropa': const Color(0xFFC026D3), // Magenta moderno
          'deportes': const Color(0xFF059669), // Verde bosque
          'viajes': const Color(0xFFEA580C), // Naranja terracota
          'regalos': const Color(0xFFBE185D), // Rojo frambuesa
          'mascotas': const Color(0xFF65A30D), // Verde lima suave
          'ahorro': const Color(0xFF0D9488), // Verde azulado
          'inversiones': const Color(0xFF7DD3FC), // Azul pastel claro
          'seguros': const Color(0xFF475569), // Gris azulado profesional
          'impuestos': const Color(0xFF991B1B), // Rojo vino
          'cuotas': const Color(0xFF9333EA), // Violeta intenso
          'otros': const Color(0xFF64748B), // Gris pizarra
        };

        return colorMap[category.toLowerCase()] ??
            const Color(0xFF6B7280); // Gris neutro para otros
      }

      return CategoryData(
        summary.categoryName,
        summary.totalAmount,
        getColorForCategory(summary.category),
        getIconForCategory(summary.category),
        summary.category,
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
                  '',
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
                  '',
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
                  '',
                ),
              ];
            }

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _refreshData,
              color: isDark ? Colors.white : Theme.of(context).primaryColor,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              strokeWidth: 2.5,
              displacement: 40,
              edgeOffset: 0,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChartSection(
                        cardColor,
                        textColor,
                        chartData,
                        isLoading,
                        context,
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

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
              if (isLoading)
                // Loader estilo circular con animación
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: AnimatedOpacity(
                                  opacity: 0.7,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeInOut,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.grey[300]!,
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              else
                Text(
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
    BuildContext context,
  ) {
    // Calcular total para porcentajes
    final totalAmount = chartData.fold<double>(
      0,
      (sum, category) => sum + category.amount,
    );

    final bool hasData = chartData.isNotEmpty && totalAmount > 0;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final primaryColorLight = primaryColor.withOpacity(0.1);
    final primaryColorExtraLight = primaryColor.withOpacity(0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Gráfico responsive
          SizedBox(
            height: MediaQuery.of(context).size.width < 350 ? 200 : 240,
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2.5,
                      ),
                    )
                    : !hasData
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryColorLight,
                                  primaryColorExtraLight,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            // child: Icon(
                            //   Icons.pie_chart_outline_rounded,
                            //   size: 56,
                            //   color: primaryColor,
                            // ),
                            child: Icon(
                              Icons.insights_outlined,
                              size: 42,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Sin datos aún',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Text(
                              'Comienza a registrar tus gastos para ver un desglose detallado por categorías',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor.withOpacity(0.6),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : SfCircularChart(
                      margin: EdgeInsets.zero,
                      series: <CircularSeries>[
                        DoughnutSeries<CategoryData, String>(
                          dataSource: chartData,
                          xValueMapper: (CategoryData data, _) => data.name,
                          yValueMapper: (CategoryData data, _) => data.amount,
                          pointColorMapper:
                              (CategoryData data, _) => data.color,
                          innerRadius:
                              MediaQuery.of(context).size.width < 350
                                  ? '60%'
                                  : '70%',
                          radius: '75%',
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width < 350
                                      ? 10
                                      : 12,
                              fontWeight: FontWeight.w500,
                            ),
                            connectorLineSettings: ConnectorLineSettings(
                              length:
                                  MediaQuery.of(context).size.width < 350
                                      ? '15%'
                                      : '20%',
                              width: 1,
                              type: ConnectorType.line,
                            ),
                            labelIntersectAction: LabelIntersectAction.none,
                            overflowMode: OverflowMode.shift,
                            // Ocultar etiquetas para porcentajes muy pequeños
                            builder: (
                              dynamic data,
                              dynamic point,
                              dynamic series,
                              int pointIndex,
                              int seriesIndex,
                            ) {
                              final percentage = (point.y / totalAmount) * 100;
                              if (percentage < 1) {
                                //! Ocultar etiquetas para porcentajes < 1%
                                return const SizedBox.shrink();
                              }

                              // Formato abreviado para pantallas pequeñas
                              String label;
                              if (MediaQuery.of(context).size.width < 350) {
                                // Pantallas pequeñas: mostrar solo porcentaje
                                label = '${percentage.toStringAsFixed(0)}%';
                              } else {
                                // Pantallas normales: mostrar monto abreviado
                                if (point.y >= 1000000) {
                                  label =
                                      '₡${(point.y / 1000000).toStringAsFixed(1)}M';
                                } else if (point.y >= 1000) {
                                  label =
                                      '₡${(point.y / 1000).toStringAsFixed(1)}K';
                                } else {
                                  // Usar formato sin decimales aquí también
                                  label = Formatters.formatCurrencyNoDecimals(
                                    point.y,
                                  );
                                }
                              }

                              return Text(
                                label,
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 10
                                          : 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          enableTooltip: true,
                        ),
                      ],
                    ),
          ),
          const SizedBox(height: 20),

          // Lista de categorías - Responsive
          isLoading
              ? _buildLoadingCategories(context)
              : !hasData
              ? Container()
              : _buildCategoriesList(
                chartData,
                totalAmount,
                textColor,
                context,
              ),
        ],
      ),
    );
  }

  Widget _buildLoadingCategories(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Círculo de color placeholder
              Container(
                width: isSmallScreen ? 10 : 12,
                height: isSmallScreen ? 10 : 12,
                decoration: BoxDecoration(
                  color: _getLoadingColor(index).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(1.5),
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              // Icono placeholder
              Container(
                width: isSmallScreen ? 14 : 16,
                height: isSmallScreen ? 14 : 16,
                decoration: BoxDecoration(
                  color: _getLoadingColor(index),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getLoadingIcon(index),
                  size: isSmallScreen ? 10 : 12,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              // Texto placeholder animado
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                      ),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedOpacity(
                            opacity: 0.5,
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOut,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.transparent,
                                    isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Monto placeholder
              Container(
                width: isSmallScreen ? 40 : 60,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para obtener colores de carga diferentes
  Color _getLoadingColor(int index) {
    final colors = [
      const Color(0xFF2563EB), // Azul
      const Color(0xFF10B981), // Verde
      const Color(0xFFF59E0B), // Naranja
      const Color(0xFF7C3AED), // Púrpura
      const Color(0xFFDB2777), // Rosa
    ];
    return colors[index % colors.length];
  }

  // Función para obtener íconos de carga diferentes
  IconData _getLoadingIcon(int index) {
    final icons = [
      Icons.shopping_bag,
      Icons.restaurant,
      Icons.home,
      Icons.directions_car,
      Icons.local_hospital,
    ];
    return icons[index % icons.length];
  }

  Widget _buildCategoriesList(
    List<CategoryData> chartData,
    double totalAmount,
    Color textColor,
    BuildContext context,
  ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Column(
      children:
          chartData.map((category) {
            final percentage =
                totalAmount > 0 ? (category.amount / totalAmount * 100) : 0;

            // Acortar nombres largos en pantallas pequeñas
            final categoryName =
                isSmallScreen && category.name.length > 10
                    ? '${category.name.substring(0, 9)}...'
                    : category.name;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: isSmallScreen ? 10 : 12,
                    height: isSmallScreen ? 10 : 12,
                    decoration: BoxDecoration(
                      color: category.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Icon(
                    category.icon,
                    color: category.color,
                    size: isSmallScreen ? 14 : 16,
                  ),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: textColor.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: isSmallScreen ? 2 : 4),
                    child: Text(
                      // Usar formato sin decimales para pantallas pequeñas también
                      Formatters.formatCurrencyNoDecimals(category.amount),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 4 : 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(percentage < 1 ? 1 : 0)}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 11,
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
