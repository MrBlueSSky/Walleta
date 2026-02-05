import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/interfaces/payment_base.dart';

class PersonalExpensePayment implements PaymentBase {
  final String userId;
  final String expenseId;
  final String payerName;
  final double amount;
  final DateTime date;
  final String? description;
  final String? paymentMethod;
  final String? receiptImageUrl;
  final DateTime? createdAt;

  PersonalExpensePayment({
    required this.userId,
    required this.expenseId,
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

  factory PersonalExpensePayment.fromMap(String id, Map<String, dynamic> map) {
    return PersonalExpensePayment(
      userId: map['userId'],
      expenseId: map['expenseId'] ?? '',
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
      'expenseId': expenseId,
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
