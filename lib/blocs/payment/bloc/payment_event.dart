// blocs/payment/bloc/payment_event.dart
import 'package:equatable/equatable.dart';
import 'package:walleta/models/payment.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {
  final String loanId;
  const LoadPayments(this.loanId);
  @override
  List<Object?> get props => [loanId];
}

class AddPayment extends PaymentEvent {
  final Payment payment;
  const AddPayment({required this.payment});
  @override
  List<Object?> get props => [payment];
}

class DeletePayment extends PaymentEvent {
  final String paymentId;
  final String loanId;
  const DeletePayment({required this.paymentId, required this.loanId});
  @override
  List<Object?> get props => [paymentId, loanId];
}
