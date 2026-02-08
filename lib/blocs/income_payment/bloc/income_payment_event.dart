part of 'income_payment_bloc.dart';

abstract class IncomePaymentEvent extends Equatable {
  const IncomePaymentEvent();

  @override
  List<Object> get props => [];
}

class LoadIncomePayments extends IncomePaymentEvent {
  final String incomeId;

  const LoadIncomePayments(this.incomeId);

  @override
  List<Object> get props => [incomeId];
}

class AddIncomePayment extends IncomePaymentEvent {
  final IncomePayment payment;
  final double newPaidAmount;

  const AddIncomePayment({required this.payment, required this.newPaidAmount});

  @override
  List<Object> get props => [payment, newPaidAmount];
}

class DeleteIncomePayment extends IncomePaymentEvent {
  final String paymentId;
  final String incomeId;
  final double newPaidAmount;

  const DeleteIncomePayment({
    required this.paymentId,
    required this.incomeId,
    required this.newPaidAmount,
  });

  @override
  List<Object> get props => [paymentId, incomeId, newPaidAmount];
}
