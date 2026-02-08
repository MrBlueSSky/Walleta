import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/interfaces/payment_base.dart';

class IncomePayment implements PaymentBase {
  final String userId;
  final String incomeId;
  final String payerName;
  final double amount;
  final DateTime date;
  final String? description;
  final String? paymentMethod;
  final String? receiptImageUrl;
  final DateTime? createdAt;

  IncomePayment({
    required this.userId,
    required this.incomeId,
    required this.payerName,
    required this.amount,
    required this.date,
    this.description,
    this.paymentMethod,
    this.receiptImageUrl,
    this.createdAt,
  });

  // Implementación de PaymentBase
  @override
  String? get note => description; // Mapeamos description a note

  // Las otras propiedades ya coinciden con la interfaz:
  // amount, date, receiptImageUrl ya existen
  // payerName también existe

  factory IncomePayment.fromMap(String id, Map<String, dynamic> map) {
    return IncomePayment(
      userId: map['userId'],
      incomeId: map['incomeId'] ?? '',
      payerName: map['payerName'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      paymentMethod: map['paymentMethod'],
      receiptImageUrl: map['receiptImageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'incomeId': incomeId,
      'payerName': payerName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'paymentMethod': paymentMethod,
      'receiptImageUrl': receiptImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
