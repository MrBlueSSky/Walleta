// models/payment_base.dart
abstract class PaymentBase {
  double get amount;
  DateTime get date;
  String? get note;
  String? get payerName;
  String? get receiptImageUrl;
}
