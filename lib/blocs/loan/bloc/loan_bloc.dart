import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_event.dart';
import 'package:walleta/blocs/loan/bloc/loan_state.dart';
import 'package:walleta/repository/loan/loan_repository.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository _repository;
  String? _currentUserId; // Guardar el userId actual

  LoanBloc({required LoanRepository loanRepository})
    : _repository = loanRepository,
      super(const LoanState.initial()) {
    on<LoadLoans>(_onLoadLoans);
    on<AddLoan>(_onAddLoan);
    on<UpdateLoan>(_onUpdateLoan);
    on<DeleteLoan>(_onDeleteLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
    _currentUserId = event.userId; // Guardar userId
    emit(const LoanState.loading());

    try {
      final loans = await _repository.fetchLoans(event.userId);
      emit(LoanState.success(loans));
    } catch (e) {
      emit(const LoanState.error());
      print('Error al cargar Loans ❌: $e');
    }
  }

  Future<void> _onAddLoan(AddLoan event, Emitter<LoanState> emit) async {
    emit(const LoanState.loading());

    try {
      await _repository.addLoan(event.loan);

      // Recargar con el userId del préstamo creado
      final loans = await _repository.fetchLoans(event.loan.lenderUserId.uid);
      emit(LoanState.success(loans));
    } catch (e) {
      emit(const LoanState.error());
      print('Error al agregar Loan ❌: $e');
    }
  }

  Future<void> _onUpdateLoan(UpdateLoan event, Emitter<LoanState> emit) async {
    // NO emitir loading aquí para evitar parpadeo en la UI
    // Mantener el estado actual mientras se actualiza

    try {
      // 1. Actualizar en el repositorio
      await _repository.updateLoan(event.loan);

      // 2. Si tenemos un userId guardado, recargar la lista
      if (_currentUserId != null) {
        final loans = await _repository.fetchLoans(_currentUserId!);
        emit(LoanState.success(loans)); // Emitir nueva lista
      } else {
        // Si no hay userId, emitir estado actualizado
        emit(const LoanState.updated());
      }
    } catch (e) {
      // En caso de error, mantener el estado actual
      emit(const LoanState.error());
      print('Error al actualizar Loan ❌: $e');
    }
  }

  Future<void> _onDeleteLoan(DeleteLoan event, Emitter<LoanState> emit) async {
    emit(const LoanState.loading());

    try {
      await _repository.deleteLoan(event.loanId);

      // Recargar si tenemos userId
      if (_currentUserId != null) {
        final loans = await _repository.fetchLoans(_currentUserId!);
        emit(LoanState.success(loans));
      } else {
        emit(const LoanState.deleted());
      }
    } catch (e) {
      emit(const LoanState.error());
      print('Error al eliminar Loan ❌: $e');
    }
  }
}
