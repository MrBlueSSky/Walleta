part of 'shared_expense_payment_bloc.dart';

abstract class ExpensePaymentEvent extends Equatable {
  const ExpensePaymentEvent();

  @override
  List<Object> get props => [];
}

class LoadExpensePayments extends ExpensePaymentEvent {
  final String expenseId;

  const LoadExpensePayments(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class AddExpensePayment extends ExpensePaymentEvent {
  final SharedExpensePayment payment;
  final double newPaidAmount;

  const AddExpensePayment({required this.payment, required this.newPaidAmount});

  @override
  List<Object> get props => [payment, newPaidAmount];
}

class DeleteExpensePayment extends ExpensePaymentEvent {
  final String paymentId;
  final String expenseId;
  final double newPaidAmount;

  const DeleteExpensePayment({
    required this.paymentId,
    required this.expenseId,
    required this.newPaidAmount,
  });

  @override
  List<Object> get props => [paymentId, expenseId, newPaidAmount];
}
