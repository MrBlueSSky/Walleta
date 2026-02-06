import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walleta/models/personal_expense_payment.dart';
import 'package:walleta/repository/personalExpensePayment/personal_expense_payment_repository.dart';
part 'personal_expense_payment_event.dart';
part 'personal_expense_payment_state.dart';

class PersonalExpensePaymentBloc
    extends Bloc<PersonalExpensePaymentEvent, PersonalExpensePaymentState> {
  final PersonalExpensePaymentRepository _repository;

  PersonalExpensePaymentBloc({
    required PersonalExpensePaymentRepository repository,
  }) : _repository = repository,
       super(const PersonalExpensePaymentState()) {
    on<LoadPersonalExpensePayments>(_onLoadPayments);
    on<AddPersonalExpensePayment>(_onAddPayment);
    on<DeletePersonalExpensePayment>(_onDeletePayment);
  }

  Future<void> _onLoadPayments(
    LoadPersonalExpensePayments event,
    Emitter<PersonalExpensePaymentState> emit,
  ) async {
    emit(state.copyWith(status: PersonalExpensePaymentStatus.loading));

    try {
      final payments = await _repository.fetchExpensePayments(event.expenseId);
      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.success,
          payments: payments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPayment(
    AddPersonalExpensePayment event,
    Emitter<PersonalExpensePaymentState> emit,
  ) async {
    emit(state.copyWith(status: PersonalExpensePaymentStatus.loading));

    try {
      // Agregar el pago
      await _repository.addExpensePayment(payment: event.payment);

      // Actualizar el monto pagado del gasto
      await _repository.updateExpensePaidAmount(
        expenseId: event.payment.expenseId,
        newPaidAmount: event.newPaidAmount,
      );

      // Recargar los pagos
      final payments = await _repository.fetchExpensePayments(
        event.payment.expenseId,
      );

      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.success,
          payments: payments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePayment(
    DeletePersonalExpensePayment event,
    Emitter<PersonalExpensePaymentState> emit,
  ) async {
    emit(state.copyWith(status: PersonalExpensePaymentStatus.loading));

    try {
      // Eliminar el pago
      await _repository.deleteExpensePayment(event.paymentId);

      // Actualizar el monto pagado del gasto
      await _repository.updateExpensePaidAmount(
        expenseId: event.expenseId,
        newPaidAmount: event.newPaidAmount,
      );

      // Recargar los pagos
      final payments = await _repository.fetchExpensePayments(event.expenseId);

      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.success,
          payments: payments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PersonalExpensePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
