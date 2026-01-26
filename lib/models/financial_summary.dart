// models/financial_summary.dart
import 'package:flutter/material.dart';

class FinancialSummary {
  final String category;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double totalAmount;
  final int transactionCount;
  final double personalAmount;
  final double sharedAmount;
  final double userPaidAmount; // Lo que el usuario realmente pagó

  const FinancialSummary({
    required this.category,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.totalAmount,
    required this.transactionCount,
    required this.personalAmount,
    required this.sharedAmount,
    required this.userPaidAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon.codePoint,
      'categoryFontFamily': categoryIcon.fontFamily,
      'categoryColor': categoryColor.value,
      'totalAmount': totalAmount,
      'transactionCount': transactionCount,
      'personalAmount': personalAmount,
      'sharedAmount': sharedAmount,
      'userPaidAmount': userPaidAmount,
    };
  }

  factory FinancialSummary.fromMap(Map<String, dynamic> map) {
    return FinancialSummary(
      category: map['category'] ?? 'other',
      categoryName: map['categoryName'] ?? 'Otros',
      categoryIcon: IconData(
        map['categoryIcon'] ?? Icons.category.codePoint,
        fontFamily: map['categoryFontFamily'] ?? 'MaterialIcons',
      ),
      categoryColor: Color(map['categoryColor'] ?? Colors.grey.value),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      transactionCount: map['transactionCount'] ?? 0,
      personalAmount: (map['personalAmount'] ?? 0.0).toDouble(),
      sharedAmount: (map['sharedAmount'] ?? 0.0).toDouble(),
      userPaidAmount: (map['userPaidAmount'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'FinancialSummary{category: $category, totalAmount: $totalAmount, '
        'transactionCount: $transactionCount}';
  }

  FinancialSummary copyWith({
    String? category,
    String? categoryName,
    IconData? categoryIcon,
    Color? categoryColor,
    double? totalAmount,
    int? transactionCount,
    double? personalAmount,
    double? sharedAmount,
    double? userPaidAmount,
  }) {
    return FinancialSummary(
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      totalAmount: totalAmount ?? this.totalAmount,
      transactionCount: transactionCount ?? this.transactionCount,
      personalAmount: personalAmount ?? this.personalAmount,
      sharedAmount: sharedAmount ?? this.sharedAmount,
      userPaidAmount: userPaidAmount ?? this.userPaidAmount,
    );
  }
}
