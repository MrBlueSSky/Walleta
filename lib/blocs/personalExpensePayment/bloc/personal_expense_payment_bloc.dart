// import 'dart:async';
// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:walleta/models/shared_expense_payment.dart';
// import 'package:walleta/repository/SharedExpensePaymentRepository/shared_expense_payment_repository.dart';

// part 'personal_expense_payment_event.dart';
// part 'personal_expense_payment_state.dart';

// class ExpensePaymentBloc
//     extends Bloc<ExpensePaymentEvent, ExpensePaymentState> {
//   final SharedExpensePaymentRepository _repository;

//   ExpensePaymentBloc({required SharedExpensePaymentRepository repository})
//     : _repository = repository,
//       super(const ExpensePaymentState()) {
//     on<LoadExpensePayments>(_onLoadPayments);
//     on<AddExpensePayment>(_onAddPayment);
//     on<DeleteExpensePayment>(_onDeletePayment);
//   }

//   Future<void> _onLoadPayments(
//     LoadExpensePayments event,
//     Emitter<ExpensePaymentState> emit,
//   ) async {
//     emit(state.copyWith(status: ExpensePaymentStatus.loading));

//     try {
//       final payments = await _repository.fetchExpensePayments(event.expenseId);
//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.success,
//           payments: payments,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> _onAddPayment(
//     AddExpensePayment event,
//     Emitter<ExpensePaymentState> emit,
//   ) async {
//     emit(state.copyWith(status: ExpensePaymentStatus.loading));

//     try {
//       // Agregar el pago
//       await _repository.addExpensePayment(payment: event.payment);

//       // Actualizar el monto pagado del gasto
//       await _repository.updateExpensePaidAmount(
//         expenseId: event.payment.expenseId,
//         newPaidAmount: event.newPaidAmount,
//       );

//       // Recargar los pagos
//       final payments = await _repository.fetchExpensePayments(
//         event.payment.expenseId,
//       );

//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.success,
//           payments: payments,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }

//   Future<void> _onDeletePayment(
//     DeleteExpensePayment event,
//     Emitter<ExpensePaymentState> emit,
//   ) async {
//     emit(state.copyWith(status: ExpensePaymentStatus.loading));

//     try {
//       // Eliminar el pago
//       await _repository.deleteExpensePayment(event.paymentId);

//       // Actualizar el monto pagado del gasto
//       await _repository.updateExpensePaidAmount(
//         expenseId: event.expenseId,
//         newPaidAmount: event.newPaidAmount,
//       );

//       // Recargar los pagos
//       final payments = await _repository.fetchExpensePayments(event.expenseId);

//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.success,
//           payments: payments,
//         ),
//       );
//     } catch (e) {
//       emit(
//         state.copyWith(
//           status: ExpensePaymentStatus.error,
//           errorMessage: e.toString(),
//         ),
//       );
//     }
//   }
// }
