part of 'personal_expense_payment_bloc.dart';

abstract class PersonalExpensePaymentEvent extends Equatable {
  const PersonalExpensePaymentEvent();

  @override
  List<Object> get props => [];
}

class LoadPersonalExpensePayments extends PersonalExpensePaymentEvent {
  final String expenseId;

  const LoadPersonalExpensePayments(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class AddPersonalExpensePayment extends PersonalExpensePaymentEvent {
  final PersonalExpensePayment payment;
  final double newPaidAmount;

  const AddPersonalExpensePayment({
    required this.payment,
    required this.newPaidAmount,
  });

  @override
  List<Object> get props => [payment, newPaidAmount];
}

class DeletePersonalExpensePayment extends PersonalExpensePaymentEvent {
  final String paymentId;
  final String expenseId;
  final double newPaidAmount;

  const DeletePersonalExpensePayment({
    required this.paymentId,
    required this.expenseId,
    required this.newPaidAmount,
  });

  @override
  List<Object> get props => [paymentId, expenseId, newPaidAmount];
}
