import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_event.dart';
import 'package:walleta/blocs/loan/bloc/loan_state.dart';
import 'package:walleta/repository/loan/loan_repository.dart';

class LoanBloc extends Bloc<LoanEvent, LoanState> {
  final LoanRepository _repository;

  LoanBloc({required LoanRepository loanRepository})
    : _repository = loanRepository,
      super(const LoanState.initial()) {
    on<LoadLoans>(_onLoadLoans);
    on<AddLoan>(_onAddLoan);
    on<UpdateLoan>(_onUpdateLoan);
    on<DeleteLoan>(_onDeleteLoan);
  }

  Future<void> _onLoadLoans(LoadLoans event, Emitter<LoanState> emit) async {
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

      final loans = await _repository.fetchLoans(event.loan.lenderUserId.uid);
      emit(LoanState.success(loans));
    } catch (e) {
      emit(const LoanState.error());
      print('Error al agregar Loan ❌: $e');
    }
  }

  Future<void> _onUpdateLoan(UpdateLoan event, Emitter<LoanState> emit) async {
    emit(const LoanState.loading());

    try {
      await _repository.updateLoan(event.loan);
      emit(const LoanState.updated());
    } catch (e) {
      emit(const LoanState.error());
      print('Error al actualizar Loan ❌: $e');
    }
  }

  Future<void> _onDeleteLoan(DeleteLoan event, Emitter<LoanState> emit) async {
    emit(const LoanState.loading());

    try {
      await _repository.deleteLoan(event.loanId);
      emit(const LoanState.deleted());
    } catch (e) {
      emit(const LoanState.error());
      print('Error al eliminar Loan ❌: $e');
    }
  }
}
