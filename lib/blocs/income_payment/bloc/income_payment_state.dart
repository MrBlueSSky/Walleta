part of 'income_payment_bloc.dart';

enum IncomePaymentStatus { initial, loading, success, error }

class IncomePaymentState extends Equatable {
  final IncomePaymentStatus status;
  final List<IncomePayment> payments;
  final String? errorMessage;

  const IncomePaymentState({
    this.status = IncomePaymentStatus.initial,
    this.payments = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, payments, errorMessage];

  IncomePaymentState copyWith({
    IncomePaymentStatus? status,
    List<IncomePayment>? payments,
    String? errorMessage,
  }) {
    return IncomePaymentState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
