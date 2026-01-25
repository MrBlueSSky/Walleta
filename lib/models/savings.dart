import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final double amount;
  final DateTime date;

  Payment({required this.amount, required this.date});

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
    };
  }
}

class SavingGoal {
  final String id;
  final String title;
  final double saved;
  final double goal;
  final IconData icon;
  final Color color;
  final DateTime targetDate;
  final List<Payment> payments;

  SavingGoal({
    this.id = '',
    required this.title,
    required this.saved,
    required this.goal,
    required this.icon,
    required this.color,
    required this.targetDate,
    this.payments = const [],
  });

  factory SavingGoal.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final paymentsData = data['payments'] as List<dynamic>? ?? [];
    return SavingGoal(
      id: doc.id,
      title: data['title'],
      saved: (data['saved'] as num).toDouble(),
      goal: (data['goal'] as num).toDouble(),
      icon: IconData(
        data['icon'],
        fontFamily: data['iconFontFamily'],
      ),
      color: Color(data['color']),
      targetDate: (data['targetDate'] as Timestamp).toDate(),
      payments: paymentsData
          .map((p) => Payment.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'userId': userId,
      'title': title,
      'saved': saved,
      'goal': goal,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'targetDate': Timestamp.fromDate(targetDate),
      'payments': payments.map((p) => p.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  SavingGoal copyWith({
    String? id,
    String? title,
    double? saved,
    double? goal,
    IconData? icon,
    Color? color,
    DateTime? targetDate,
    List<Payment>? payments,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      saved: saved ?? this.saved,
      goal: goal ?? this.goal,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetDate: targetDate ?? this.targetDate,
      payments: payments ?? this.payments,
    );
  }
}
