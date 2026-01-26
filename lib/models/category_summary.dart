// models/category_expense_summary.dart
class CategoryExpenseSummary {
  final String category;
  final double totalAmount;
  final int count;
  final double personalAmount;
  final double sharedAmount;

  const CategoryExpenseSummary({
    required this.category,
    required this.totalAmount,
    required this.count,
    required this.personalAmount,
    required this.sharedAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'totalAmount': totalAmount,
      'count': count,
      'personalAmount': personalAmount,
      'sharedAmount': sharedAmount,
    };
  }

  factory CategoryExpenseSummary.fromMap(Map<String, dynamic> map) {
    return CategoryExpenseSummary(
      category: map['category'] ?? '',
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      count: map['count'] ?? 0,
      personalAmount: (map['personalAmount'] ?? 0.0).toDouble(),
      sharedAmount: (map['sharedAmount'] ?? 0.0).toDouble(),
    );
  }
}
