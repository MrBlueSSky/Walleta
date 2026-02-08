// repository/financial_summary/financial_summary_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/financial_summary.dart';
import 'package:walleta/models/personal_expense_payment.dart';
import 'package:walleta/models/shared_expense_payment.dart';

class FinancialSummaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FinancialSummaryRepository();

  // Método principal para obtener el resumen financiero completo
  Future<Map<String, dynamic>> getFinancialSummary(String userId) async {
    try {
      print('\n🔍 === INICIANDO RESUMEN FINANCIERO PARA: $userId ===');

      // 1. Obtener pagos de gastos compartidos agrupados por categoría
      final sharedPaymentsByCategory = await _getSharedPaymentsByCategory(
        userId,
      );

      // 2. Obtener pagos de gastos personales agrupados por categoría
      final personalPaymentsByCategory = await _getPersonalPaymentsByCategory(
        userId,
      );

      // 3. Combinar y procesar todo
      final categorySummaries = await _categorizeExpenses(
        sharedPaymentsByCategory,
        personalPaymentsByCategory,
      );

      print(
        '✅ Resumen financiero completado: ${categorySummaries.length} categorías',
      );
      return {'summaries': categorySummaries};
    } catch (e) {
      print('❌ Error en FinancialSummaryRepository: $e');
      throw Exception('No se pudo obtener el resumen financiero: $e');
    }
  }

  // Método para obtener pagos de gastos compartidos por categoría
  Future<Map<String, Map<String, dynamic>>> _getSharedPaymentsByCategory(
    String userId,
  ) async {
    try {
      print('🔍 Obteniendo pagos de gastos compartidos...');

      final paymentsSnapshot =
          await _firestore
              .collection('shared_expenses_payments')
              .where('userId', isEqualTo: userId)
              .get();

      print(
        '📊 Pagos compartidos encontrados: ${paymentsSnapshot.docs.length}',
      );

      final Map<String, Map<String, dynamic>> paymentsMap = {};

      for (final paymentDoc in paymentsSnapshot.docs) {
        try {
          final paymentData = paymentDoc.data();
          final expenseId = paymentData['expenseId'] as String?;

          if (expenseId != null && expenseId.isNotEmpty) {
            double amount = 0.0;

            // Procesar el amount
            if (paymentData.containsKey('amount')) {
              final amountValue = paymentData['amount'];
              if (amountValue is int) {
                amount = amountValue.toDouble();
              } else if (amountValue is double) {
                amount = amountValue;
              } else if (amountValue is num) {
                amount = amountValue.toDouble();
              }
            }

            if (amount > 0) {
              // Obtener la categoría del gasto compartido
              final categoryInfo = await _getSharedExpenseCategory(expenseId);
              final category = categoryInfo['category'] as String;

              if (category.isNotEmpty) {
                // Acumular por categoría
                if (paymentsMap.containsKey(category)) {
                  final current = paymentsMap[category]!;
                  paymentsMap[category] = {
                    'totalAmount': (current['totalAmount'] as double) + amount,
                    'count': (current['count'] as int) + 1,
                    'sharedAmount':
                        (current['sharedAmount'] as double) + amount,
                    'categoryIcon': current['categoryIcon'],
                    'categoryColor': current['categoryColor'],
                  };
                } else {
                  paymentsMap[category] = {
                    'totalAmount': amount,
                    'count': 1,
                    'sharedAmount': amount,
                    'categoryIcon': categoryInfo['categoryIcon'],
                    'categoryColor': categoryInfo['categoryColor'],
                  };
                }
              }
            }
          }
        } catch (e) {
          print('⚠️ Error procesando pago compartido ${paymentDoc.id}: $e');
        }
      }

      print('✅ Pagos compartidos procesados: ${paymentsMap.length} categorías');
      return paymentsMap;
    } catch (e) {
      print('❌ Error obteniendo pagos compartidos: $e');
      return {};
    }
  }

  // Método para obtener pagos de gastos personales por categoría
  Future<Map<String, Map<String, dynamic>>> _getPersonalPaymentsByCategory(
    String userId,
  ) async {
    try {
      print('🔍 Obteniendo pagos de gastos personales...');

      final paymentsSnapshot =
          await _firestore
              .collection('personal_expenses_payments')
              .where('userId', isEqualTo: userId)
              .get();

      print('📊 Pagos personales encontrados: ${paymentsSnapshot.docs.length}');

      final Map<String, Map<String, dynamic>> paymentsMap = {};

      for (final paymentDoc in paymentsSnapshot.docs) {
        try {
          final paymentData = paymentDoc.data();
          final expenseId = paymentData['expenseId'] as String?;

          if (expenseId != null && expenseId.isNotEmpty) {
            double amount = 0.0;

            // Procesar el amount
            if (paymentData.containsKey('amount')) {
              final amountValue = paymentData['amount'];
              if (amountValue is int) {
                amount = amountValue.toDouble();
              } else if (amountValue is double) {
                amount = amountValue;
              } else if (amountValue is num) {
                amount = amountValue.toDouble();
              }
            }

            if (amount > 0) {
              // Obtener la categoría del gasto personal
              final categoryInfo = await _getPersonalExpenseCategory(expenseId);
              final category = categoryInfo['category'] as String;

              if (category.isNotEmpty) {
                // Acumular por categoría
                if (paymentsMap.containsKey(category)) {
                  final current = paymentsMap[category]!;
                  paymentsMap[category] = {
                    'totalAmount': (current['totalAmount'] as double) + amount,
                    'count': (current['count'] as int) + 1,
                    'personalAmount':
                        (current['personalAmount'] as double) + amount,
                    'categoryIcon': current['categoryIcon'],
                    'categoryColor': current['categoryColor'],
                  };
                } else {
                  paymentsMap[category] = {
                    'totalAmount': amount,
                    'count': 1,
                    'personalAmount': amount,
                    'categoryIcon': categoryInfo['categoryIcon'],
                    'categoryColor': categoryInfo['categoryColor'],
                  };
                }
              }
            }
          }
        } catch (e) {
          print('⚠️ Error procesando pago personal ${paymentDoc.id}: $e');
        }
      }

      print('✅ Pagos personales procesados: ${paymentsMap.length} categorías');
      return paymentsMap;
    } catch (e) {
      print('❌ Error obteniendo pagos personales: $e');
      return {};
    }
  }

  // Obtener la categoría, ícono y color de un gasto compartido
  Future<Map<String, dynamic>> _getSharedExpenseCategory(
    String expenseId,
  ) async {
    try {
      final expenseDoc =
          await _firestore.collection('shared_expenses').doc(expenseId).get();

      if (expenseDoc.exists) {
        final expenseData = expenseDoc.data();
        return _processCategoryData(expenseData);
      }

      return _getDefaultCategoryInfo();
    } catch (e) {
      print(
        '⚠️ Error obteniendo categoría compartida para expenseId $expenseId: $e',
      );
      return _getDefaultCategoryInfo();
    }
  }

  // Obtener la categoría, ícono y color de un gasto personal
  Future<Map<String, dynamic>> _getPersonalExpenseCategory(
    String expenseId,
  ) async {
    try {
      final expenseDoc =
          await _firestore.collection('personal_expenses').doc(expenseId).get();

      if (expenseDoc.exists) {
        final expenseData = expenseDoc.data();
        return _processCategoryData(expenseData);
      }

      return _getDefaultCategoryInfo();
    } catch (e) {
      print(
        '⚠️ Error obteniendo categoría personal para expenseId $expenseId: $e',
      );
      return _getDefaultCategoryInfo();
    }
  }

  // Procesar datos de categoría de forma genérica
  Map<String, dynamic> _processCategoryData(Map<String, dynamic>? expenseData) {
    final category = expenseData?['category']?.toString() ?? 'Otros';
    final categoryIconCode = expenseData?['categoryIcon'] as int? ?? 0;
    final categoryFontFamily =
        expenseData?['categoryFontFamily']?.toString() ?? 'MaterialIcons';
    final categoryColorValue =
        expenseData?['categoryColor'] as int? ?? 0xFF9CA3AF;

    // Si no hay icono en la BD, usar uno por defecto basado en la categoría
    final (finalIconCode, finalColorValue) =
        categoryIconCode == 0
            ? _getCategoryIconAndColor(category)
            : (categoryIconCode, categoryColorValue);

    return {
      'category': category,
      'categoryIcon': finalIconCode,
      'categoryFontFamily': categoryFontFamily,
      'categoryColor': finalColorValue,
    };
  }

  // Información de categoría por defecto
  Map<String, dynamic> _getDefaultCategoryInfo() {
    return {
      'category': 'Otros',
      'categoryIcon': Icons.category.codePoint,
      'categoryFontFamily': 'MaterialIcons',
      'categoryColor': 0xFF9CA3AF,
    };
  }

  // Obtener ícono y color por categoría
  (int, int) _getCategoryIconAndColor(String category) {
    final Map<String, (IconData, Color)> categoryMap = {
      'Comida': (Icons.restaurant, Color(0xFFEF4444)),
      'Transporte': (Icons.directions_car, Color(0xFF3B82F6)),
      'Hogar': (Icons.home, Color(0xFF10B981)),
      'Entretenimiento': (Icons.movie, Color(0xFF8B5CF6)),
      'Salud': (Icons.local_hospital, Color(0xFFEC4899)),
      'Educación': (Icons.school, Color(0xFFF59E0B)),
      'Servicios': (Icons.build, Color(0xFF6366F1)),
      'Ropa': (Icons.shopping_bag, Color(0xFF8B5CF6)),
      'Otros': (Icons.category, Color(0xFF9CA3AF)),
    };

    final (icon, color) =
        categoryMap[category] ?? (Icons.category, Color(0xFF9CA3AF));
    return (icon.codePoint, color.value);
  }

  // Categorizar y sumar todos los gastos
  Future<List<FinancialSummary>> _categorizeExpenses(
    Map<String, Map<String, dynamic>> sharedPaymentsByCategory,
    Map<String, Map<String, dynamic>> personalPaymentsByCategory,
  ) async {
    final Map<String, FinancialSummary> summaryMap = {};

    // Procesar pagos de gastos compartidos
    sharedPaymentsByCategory.forEach((category, data) {
      final totalAmount = data['totalAmount'] as double;
      final count = data['count'] as int;
      final sharedAmount = data['sharedAmount'] as double;
      final categoryIconCode = data['categoryIcon'] as int;
      final categoryFontFamily =
          data['categoryFontFamily'] as String? ?? 'MaterialIcons';
      final categoryColorValue = data['categoryColor'] as int? ?? 0xFF9CA3AF;

      final IconData categoryIcon = IconData(
        categoryIconCode,
        fontFamily: categoryFontFamily,
      );
      final Color categoryColor = Color(categoryColorValue);

      summaryMap[category] = FinancialSummary(
        category: category,
        categoryName: category,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        totalAmount: totalAmount,
        transactionCount: count,
        personalAmount: 0.0,
        sharedAmount: sharedAmount,
        userPaidAmount: totalAmount,
      );
    });

    // Procesar pagos de gastos personales
    personalPaymentsByCategory.forEach((category, data) {
      final totalAmount = data['totalAmount'] as double;
      final count = data['count'] as int;
      final personalAmount = data['personalAmount'] as double;
      final categoryIconCode = data['categoryIcon'] as int;
      final categoryFontFamily =
          data['categoryFontFamily'] as String? ?? 'MaterialIcons';
      final categoryColorValue = data['categoryColor'] as int? ?? 0xFF9CA3AF;

      final IconData categoryIcon = IconData(
        categoryIconCode,
        fontFamily: categoryFontFamily,
      );
      final Color categoryColor = Color(categoryColorValue);

      if (summaryMap.containsKey(category)) {
        final current = summaryMap[category]!;
        summaryMap[category] = current.copyWith(
          totalAmount: current.totalAmount + totalAmount,
          transactionCount: current.transactionCount + count,
          personalAmount: current.personalAmount + personalAmount,
          userPaidAmount: current.userPaidAmount + totalAmount,
        );
      } else {
        summaryMap[category] = FinancialSummary(
          category: category,
          categoryName: category,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
          totalAmount: totalAmount,
          transactionCount: count,
          personalAmount: personalAmount,
          sharedAmount: 0.0,
          userPaidAmount: totalAmount,
        );
      }
    });

    // Convertir a lista y ordenar por monto total descendente
    final List<FinancialSummary> summaries =
        summaryMap.values.toList()
          ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }

  // Método de debug para ver la estructura
  Future<void> debugDataStructure(String userId) async {
    try {
      print('\n🔍 === DEBUG: ESTRUCTURA DE DATOS ===');

      // Ver pagos compartidos
      final sharedPayments =
          await _firestore
              .collection('shared_expenses_payments')
              .where('userId', isEqualTo: userId)
              .limit(3)
              .get();

      print('📋 PAGOS COMPARTIDOS (primeros 3):');
      for (final doc in sharedPayments.docs) {
        print('  ID: ${doc.id}');
        print('  Datos: ${doc.data()}');
        final expenseId = doc.data()['expenseId'];
        if (expenseId != null) {
          final expenseDoc =
              await _firestore
                  .collection('shared_expenses')
                  .doc(expenseId)
                  .get();
          print('  Categoría del gasto: ${expenseDoc.data()?['category']}');
        }
      }

      // Ver pagos personales
      final personalPayments =
          await _firestore
              .collection('personal_expenses_payments')
              .where('userId', isEqualTo: userId)
              .limit(3)
              .get();

      print('\n📋 PAGOS PERSONALES (primeros 3):');
      for (final doc in personalPayments.docs) {
        print('  ID: ${doc.id}');
        print('  Datos: ${doc.data()}');
        final expenseId = doc.data()['expenseId'];
        if (expenseId != null) {
          final expenseDoc =
              await _firestore
                  .collection('personal_expenses')
                  .doc(expenseId)
                  .get();
          print('  Categoría del gasto: ${expenseDoc.data()?['category']}');
        }
      }

      print('====================================\n');
    } catch (e) {
      print('❌ Error en debug: $e');
    }
  }
}
