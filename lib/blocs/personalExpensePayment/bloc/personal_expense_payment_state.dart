// part of 'shared_expense_payment_bloc.dart';

// enum ExpensePaymentStatus { initial, loading, success, error }

// class ExpensePaymentState extends Equatable {
//   final ExpensePaymentStatus status;
//   final List<SharedExpensePayment> payments;
//   final String? errorMessage;

//   const ExpensePaymentState({
//     this.status = ExpensePaymentStatus.initial,
//     this.payments = const [],
//     this.errorMessage,
//   });

//   @override
//   List<Object?> get props => [status, payments, errorMessage];

//   ExpensePaymentState copyWith({
//     ExpensePaymentStatus? status,
//     List<SharedExpensePayment>? payments,
//     String? errorMessage,
//   }) {
//     return ExpensePaymentState(
//       status: status ?? this.status,
//       payments: payments ?? this.payments,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }
