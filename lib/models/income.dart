import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Incomes {
  final String? id;
  final String title;
  final double total;
  final double paid;
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final String? status;
  final DateTime? date;

  Incomes({
    this.id,
    required this.title,
    required this.total,
    required this.paid,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    this.status,
    this.date,
  });

  factory Incomes.fromMap(String id, Map<String, dynamic> map) {
    return Incomes(
      id: id,
      title: map['title'],
      total: (map['total'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      category: map['category'],
      categoryIcon: IconData(
        map['categoryIcon'],
        fontFamily: map['categoryFontFamily'],
      ),
      categoryColor: Color(map['categoryColor']),
      status: map['status'],
      date: (map['date'] as Timestamp?)?.toDate(),
    );
  }

  /// 👉 Para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'total': total,
      'paid': paid,
      'category': category,
      'categoryIcon': categoryIcon.codePoint,
      'categoryFontFamily': categoryIcon.fontFamily,
      'categoryColor': categoryColor.value,
      'date': date != null ? Timestamp.fromDate(date!) : null,
    };
  }
}
