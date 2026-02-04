// repository/financial_summary/financial_summary_repository.dart
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/financial_summary.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/personal_expense.dart';

class FinancialSummaryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FinancialSummaryRepository();

  // Método principal para obtener el resumen financiero completo
  Future<Map<String, dynamic>> getFinancialSummary(String userId) async {
    try {
      // 1. Obtener todos los pagos del usuario con sus detalles
      final userPaymentsWithDetails = await _getUserPaymentsWithCategory(
        userId,
      );

      // 2. Obtener gastos personales

      final personalExpenses = await _fetchPersonalExpenses(userId);

      // 3. Procesar todo junto
      final categorySummaries = await _categorizeExpenses(
        userPaymentsWithDetails,
        personalExpenses,
      );

      return {'summaries': categorySummaries};
    } catch (e) {
      print('❌ Error en FinancialSummaryRepository: $e');
      throw Exception('No se pudo obtener el resumen financiero: $e');
    }
  }

  // Método CORREGIDO: Obtener pagos del usuario con la categoría del gasto
  Future<Map<String, Map<String, dynamic>>> _getUserPaymentsWithCategory(
    String userId,
  ) async {
    try {
      // Primero, obtener todos los pagos del usuario
      final paymentsSnapshot =
          await _firestore
              .collection('shared_expenses_payments')
              .where('userId', isEqualTo: userId)
              .get();

      final Map<String, Map<String, dynamic>> paymentsMap = {};

      // Para cada pago, obtener la categoría del gasto compartido
      for (final paymentDoc in paymentsSnapshot.docs) {
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
            final categoryInfo = await _getExpenseCategory(expenseId);

            if (categoryInfo['category'] != null) {
              final category = categoryInfo['category'] as String;

              // Acumular por categoría
              if (paymentsMap.containsKey(category)) {
                final current = paymentsMap[category]!;
                paymentsMap[category] = {
                  'totalAmount': (current['totalAmount'] as double) + amount,
                  'count': (current['count'] as int) + 1,
                  'sharedAmount': (current['sharedAmount'] as double) + amount,
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
      }

      return paymentsMap;
    } catch (e) {
      print('❌ Error obteniendo pagos con categoría: $e');
      return {};
    }
  }

  // Obtener la categoría, ícono y color de un gasto compartido
  Future<Map<String, dynamic>> _getExpenseCategory(String expenseId) async {
    try {
      final expenseDoc =
          await _firestore.collection('shared_expenses').doc(expenseId).get();

      if (expenseDoc.exists) {
        final expenseData = expenseDoc.data();
        return {
          'category': expenseData?['category'] ?? 'Otros',
          'categoryIcon': expenseData?['categoryIcon'] ?? 0,
          'categoryFontFamily':
              expenseData?['categoryFontFamily'] ?? 'MaterialIcons',
          'categoryColor': expenseData?['categoryColor'] ?? 0xFF9CA3AF,
        };
      }
      return {
        'category': 'Otros',
        'categoryIcon': 0,
        'categoryFontFamily': 'MaterialIcons',
        'categoryColor': 0xFF9CA3AF,
      };
    } catch (e) {
      print('⚠️ Error obteniendo categoría para expenseId $expenseId: $e');
      return {
        'category': 'Otros',
        'categoryIcon': 0,
        'categoryFontFamily': 'MaterialIcons',
        'categoryColor': 0xFF9CA3AF,
      };
    }
  }

  // Obtener gastos personales del usuario
  Future<List<PersonalExpense>> _fetchPersonalExpenses(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('personal_expenses')
              .where('userId', isEqualTo: userId)
              .get();

      return snapshot.docs.map((doc) {
        return PersonalExpense.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Error al obtener gastos personales: $e');
      return [];
    }
  }

  // Categorizar y sumar todos los gastos - VERSIÓN CORREGIDA
  Future<List<FinancialSummary>> _categorizeExpenses(
    Map<String, Map<String, dynamic>> sharedPaymentsByCategory,
    List<PersonalExpense> personalExpenses,
  ) async {
    final Map<String, FinancialSummary> summaryMap = {};

    // Procesar pagos en gastos compartidos (ya están agrupados por categoría)
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
        userPaidAmount:
            totalAmount, // En compartidos, userPaidAmount = lo que pagó
      );
    });

    // Procesar gastos personales
    for (final expense in personalExpenses) {
      final category = expense.category;

      if (summaryMap.containsKey(category)) {
        final current = summaryMap[category]!;
        summaryMap[category] = current.copyWith(
          totalAmount: current.totalAmount + expense.total,
          transactionCount: current.transactionCount + 1,
          personalAmount: current.personalAmount + expense.total,
          userPaidAmount: current.userPaidAmount + expense.total,
        );
      } else {
        summaryMap[category] = FinancialSummary(
          category: category,
          categoryName: expense.category,
          categoryIcon: expense.categoryIcon,
          categoryColor: expense.categoryColor,
          totalAmount: expense.total,
          transactionCount: 1,
          personalAmount: expense.total,
          sharedAmount: 0.0,
          userPaidAmount: expense.total,
        );
      }
    }

    // Convertir a lista y ordenar por monto total descendente
    final List<FinancialSummary> summaries =
        summaryMap.values.toList()
          ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }

  // Método auxiliar para debug
  Future<void> debugPaymentsStructure(String userId) async {
    try {
      print('=== DEBUG: ESTRUCTURA DE PAGOS ===');

      // Ver pagos
      final paymentsSnapshot =
          await _firestore
              .collection('shared_expenses_payments')
              .where('userId', isEqualTo: userId)
              .limit(5)
              .get();

      // Ver gastos compartidos relacionados
      for (final doc in paymentsSnapshot.docs) {
        final expenseId = doc.data()['expenseId'];
        if (expenseId != null) {
          await _firestore.collection('shared_expenses').doc(expenseId).get();
        }
      }
    } catch (e) {
      print('Error en debug: $e');
    }
  }
}
