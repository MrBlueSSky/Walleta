// blocs/payment/bloc/payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:walleta/models/payment.dart';

enum PaymentStateStatus { initial, success, loading, error }

class PaymentState extends Equatable {
  final PaymentStateStatus status;
  final List<Payment> payments;

  const PaymentState({
    this.status = PaymentStateStatus.initial,
    this.payments = const [],
  });

  const PaymentState.initial() : this(status: PaymentStateStatus.initial);
  const PaymentState.loading() : this(status: PaymentStateStatus.loading);
  const PaymentState.success(List<Payment> payments)
    : this(status: PaymentStateStatus.success, payments: payments);
  const PaymentState.error() : this(status: PaymentStateStatus.error);

  @override
  List<Object?> get props => [status, payments];
}
