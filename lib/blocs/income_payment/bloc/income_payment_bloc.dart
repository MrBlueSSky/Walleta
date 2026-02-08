import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walleta/models/income_payment.dart';
import 'package:walleta/repository/incomePayment/income_payment_repository.dart';

part 'income_payment_event.dart';
part 'income_payment_state.dart';

class IncomesPaymentBloc extends Bloc<IncomePaymentEvent, IncomePaymentState> {
  final IncomePaymentRepository _repository;

  IncomesPaymentBloc({required IncomePaymentRepository repository})
    : _repository = repository,
      super(const IncomePaymentState()) {
    on<LoadIncomePayments>(_onLoadPayments);
    on<AddIncomePayment>(_onAddPayment);
    on<DeleteIncomePayment>(_onDeletePayment);
  }

  Future<void> _onLoadPayments(
    LoadIncomePayments event,
    Emitter<IncomePaymentState> emit,
  ) async {
    emit(state.copyWith(status: IncomePaymentStatus.loading));

    try {
      final payments = await _repository.fetchIncomePayments(event.incomeId);
      emit(
        state.copyWith(status: IncomePaymentStatus.success, payments: payments),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: IncomePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddPayment(
    AddIncomePayment event,
    Emitter<IncomePaymentState> emit,
  ) async {
    emit(state.copyWith(status: IncomePaymentStatus.loading));

    try {
      // Agregar el pago
      await _repository.addIncomePayment(payment: event.payment);
      // Actualizar el monto pagado del ingreso
      await _repository.updateIncomePaidAmount(
        incomeId: event.payment.incomeId,
        newPaidAmount: event.newPaidAmount,
      );

      // Recargar los pagos
      final payments = await _repository.fetchIncomePayments(
        event.payment.incomeId,
      );

      emit(
        state.copyWith(status: IncomePaymentStatus.success, payments: payments),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: IncomePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePayment(
    DeleteIncomePayment event,
    Emitter<IncomePaymentState> emit,
  ) async {
    emit(state.copyWith(status: IncomePaymentStatus.loading));

    try {
      // Eliminar el pago
      await _repository.deleteIncomePayment(event.paymentId);
      // Actualizar el monto pagado del ingreso
      await _repository.updateIncomePaidAmount(
        incomeId: event.incomeId,
        newPaidAmount: event.newPaidAmount,
      );

      // Recargar los pagos
      final payments = await _repository.fetchIncomePayments(event.incomeId);

      emit(
        state.copyWith(status: IncomePaymentStatus.success, payments: payments),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: IncomePaymentStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
