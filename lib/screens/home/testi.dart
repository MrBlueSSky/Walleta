import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_event.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_state.dart';
import 'package:walleta/repository/FinancialSummary/financial_summary_repository.dart';

// En tu pantalla o widget
class FinancialSummaryScreen extends StatelessWidget {
  final String userId;

  const FinancialSummaryScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen Financiero'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<FinancialSummaryBloc>().add(
                RefreshFinancialSummary(userId),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              // Para debuggear
              // FinancialSummaryRepository().debugDataStructure();
            },
          ),
        ],
      ),
      body: BlocBuilder<FinancialSummaryBloc, FinancialSummaryState>(
        builder: (context, state) {
          if (state is FinancialSummaryLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is FinancialSummaryLoaded) {
            return _buildSummaryContent(state);
          }

          if (state is FinancialSummaryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FinancialSummaryBloc>().add(
                        LoadFinancialSummary(userId),
                      );
                    },
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text('Presiona cargar para ver el resumen'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<FinancialSummaryBloc>().add(
            LoadFinancialSummary(userId),
          );
        },
        child: Icon(Icons.calculate),
      ),
    );
  }

  Widget _buildSummaryContent(FinancialSummaryLoaded state) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Totales
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'TOTALES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //   Column(
                    //     children: [
                    //       Text('General'),
                    //       Text(
                    //         '\$${state.total.totalGeneral.toStringAsFixed(2)}',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   Column(
                    //     children: [
                    //       Text('Personal'),
                    //       Text(
                    //         '\$${state.total.totalPersonal.toStringAsFixed(2)}',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.green,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    //   Column(
                    //     children: [
                    //       Text('Compartido'),
                    //       Text(
                    //         '\$${state.total.totalShared.toStringAsFixed(2)}',
                    //         style: TextStyle(
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.orange,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(),
                SizedBox(height: 8),
                Text(
                  'TÚ HAS PAGADO:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // Text(
                //   '\$${state.total.totalUserPaid.toStringAsFixed(2)}',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.purple,
                //   ),
                // ),
                // Text(
                //   '${state.total.totalTransactions} transacciones',
                //   style: TextStyle(color: Colors.grey),
                // ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Por categoría
        Text(
          'POR CATEGORÍA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...state.summaries.map((summary) {
          return Card(
            margin: EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: summary.categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(summary.categoryIcon, color: summary.categoryColor),
              ),
              title: Text(summary.categoryName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          'Personal: \$${summary.personalAmount.toStringAsFixed(2)}',
                        ),
                        backgroundColor: Colors.green.withOpacity(0.1),
                      ),
                      SizedBox(width: 4),
                      Chip(
                        label: Text(
                          'Compartido: \$${summary.sharedAmount.toStringAsFixed(2)}',
                        ),
                        backgroundColor: Colors.orange.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${summary.totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tú: \$${summary.userPaidAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
