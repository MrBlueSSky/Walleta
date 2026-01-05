import 'dart:ui';

class LoanData {
  final String name;
  final String description;
  final double amount;
  final String date;
  final String status;
  final double progress;
  final Color color;

  LoanData({
    required this.name,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    required this.progress,
    required this.color,
  });

  // Optional: Add copyWith method for immutability
  LoanData copyWith({
    String? name,
    String? description,
    double? amount,
    String? date,
    String? status,
    double? progress,
    Color? color,
  }) {
    return LoanData(
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      color: color ?? this.color,
    );
  }
}
