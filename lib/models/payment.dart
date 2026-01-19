import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String loanId;
  final String userId;
  final double amount;
  final DateTime date;
  final String? receiptImageUrl;
  final String? note;

  Payment({
    required this.id,
    required this.loanId,
    required this.userId,
    required this.amount,
    required this.date,
    this.receiptImageUrl,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'userId': userId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'receiptImageUrl': receiptImageUrl,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Payment.fromMap(String id, Map<String, dynamic> map) {
    return Payment(
      id: id,
      loanId: map['loanId'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      receiptImageUrl: map['receiptImageUrl'],
      note: map['note'],
    );
  }
}
