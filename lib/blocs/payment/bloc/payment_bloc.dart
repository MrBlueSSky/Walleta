// blocs/payment/bloc/payment_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_event.dart';
import 'package:walleta/blocs/payment/bloc/payment_state.dart';
import 'package:walleta/repository/payment/payment.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;

  PaymentBloc({required PaymentRepository paymentRepository})
    : _repository = paymentRepository,
      super(const PaymentState.initial()) {
    on<LoadPayments>(_onLoadPayments);
    on<AddPayment>(_onAddPayment);
    on<DeletePayment>(_onDeletePayment);
  }

  Future<void> _onLoadPayments(
    LoadPayments event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      final payments = await _repository.fetchPaymentsByLoan(event.loanId);
      emit(PaymentState.success(payments));
    } catch (e) {
      emit(const PaymentState.error());
      print('Error al cargar pagos: $e');
    }
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      await _repository.addPaymentWithImage(payment: event.payment);

      // Recargar la lista de pagos
      final payments = await _repository.fetchPaymentsByLoan(
        event.payment.loanId,
      );
      emit(PaymentState.success(payments));
    } catch (e) {
      emit(const PaymentState.error());
      print('Error al agregar pago: $e');
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      await _repository.deletePayment(event.paymentId);

      // Recargar la lista de pagos
      final payments = await _repository.fetchPaymentsByLoan(event.loanId);
      emit(PaymentState.success(payments));
    } catch (e) {
      emit(const PaymentState.error());
      print('Error al eliminar pago: $e');
    }
  }
}
