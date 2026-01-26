// En blocs/payment/bloc/payment_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_event.dart';
import 'package:walleta/blocs/payment/bloc/payment_state.dart';
import 'package:walleta/repository/payment/payment.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _repository;
  String? _currentUserId;

  PaymentBloc({required PaymentRepository paymentRepository})
    : _repository = paymentRepository,
      super(const PaymentState.initial()) {
    on<LoadPayments>(_onLoadPayments);
    on<LoadAllPaymentsForUser>(
      _onLoadAllPaymentsForUser,
    ); // ✅ Agregar este handler
    on<AddPayment>(_onAddPayment);
    on<DeletePayment>(_onDeletePayment);
    on<LoadPaymentsByLoanIds>(_onLoadPaymentsByLoanIds);
  }

  Future<void> _onLoadAllPaymentsForUser(
    LoadAllPaymentsForUser event,
    Emitter<PaymentState> emit,
  ) async {
    _currentUserId = event.userId; // ✅ Guardar userId para futuras recargas
    emit(const PaymentState.loading());
    try {
      final payments = await _repository.fetchPaymentsByUser(event.userId);

      emit(PaymentState.success(payments));
    } catch (e) {
      print('❌ Error al cargar todos los pagos del usuario: $e');
      emit(const PaymentState.error());
    }
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
      print('❌ Error al cargar pagos: $e');
      emit(const PaymentState.error());
    }
  }

  Future<void> _onLoadPaymentsByLoanIds(
    LoadPaymentsByLoanIds event,
    Emitter<PaymentState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(const PaymentState.loading());

    try {
      final payments = await _repository.fetchPaymentsByLoanIds(event.loanIds);

      emit(PaymentState.success(payments));
    } catch (e) {
      print('❌ Error al cargar pagos por loanIds: $e');
      emit(const PaymentState.error());
    }
  }

  Future<void> _onAddPayment(
    AddPayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      await _repository.addPaymentWithImage(payment: event.payment);

      // ✅ IMPORTANTE: Recargar TODOS los pagos del usuario, no solo del préstamo
      if (_currentUserId != null) {
        print(
          '🔄 Recargando TODOS los pagos del usuario después de agregar uno nuevo',
        );
        final payments = await _repository.fetchPaymentsByUser(_currentUserId!);
        emit(PaymentState.success(payments));
      } else {
        // Si por alguna razón no tenemos userId, recargar por préstamo
        final payments = await _repository.fetchPaymentsByLoan(
          event.payment.loanId,
        );
        emit(PaymentState.success(payments));
      }
    } catch (e) {
      print('❌ Error al agregar pago: $e');
      emit(const PaymentState.error());
    }
  }

  Future<void> _onDeletePayment(
    DeletePayment event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentState.loading());
    try {
      await _repository.deletePayment(event.paymentId);

      // ✅ Recargar TODOS los pagos del usuario
      if (_currentUserId != null) {
        print('🔄 Recargando TODOS los pagos del usuario después de eliminar');
        final payments = await _repository.fetchPaymentsByUser(_currentUserId!);
        emit(PaymentState.success(payments));
      } else {
        final payments = await _repository.fetchPaymentsByLoan(event.loanId);
        emit(PaymentState.success(payments));
      }
    } catch (e) {
      print('❌ Error al eliminar pago: $e');
      emit(const PaymentState.error());
    }
  }
}
