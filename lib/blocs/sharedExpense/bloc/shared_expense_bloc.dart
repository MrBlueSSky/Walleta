import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_state.dart';
import 'package:walleta/repository/sharedExpense/shared_expense_repository.dart';

class SharedExpenseBloc extends Bloc<SharedExpenseEvent, SharedExpenseState> {
  final SharedExpenseRepository _repository;

  SharedExpenseBloc({required SharedExpenseRepository sharedExpenseRepository})
    : _repository = sharedExpenseRepository,
      super(const SharedExpenseState.initial()) {
    on<LoadSharedExpenses>(_onLoadSharedExpenses);
    on<AddSharedExpense>(_onAddSharedExpense);
    on<DeleteSharedExpense>(_onDeleteSharedExpense);
    on<UpdateSharedExpense>(_onUpdateSharedExpense);
  }

  Future<void> _onLoadSharedExpenses(
    LoadSharedExpenses event,
    Emitter<SharedExpenseState> emit,
  ) async {
    emit(const SharedExpenseState.loading());

    try {
      final expenses = await _repository.fetchSharedExpenses(event.userId);
      emit(SharedExpenseState.success(expenses));
    } catch (e) {
      emit(const SharedExpenseState.error());
      print('Error al cargar SharedExpenses ❌: $e');
    }
  }

  Future<void> _onAddSharedExpense(
    AddSharedExpense event,
    Emitter<SharedExpenseState> emit,
  ) async {
    emit(const SharedExpenseState.loading());

    try {
      await _repository.addSharedExpense(
        userId: event.userId,
        expense: event.expense,
      );

      final expenses = await _repository.fetchSharedExpenses(event.userId);

      emit(SharedExpenseState.success(expenses));
    } catch (e) {
      emit(const SharedExpenseState.error());
      print('Error al agregar SharedExpense ❌: $e');
    }
  }

  Future<void> _onDeleteSharedExpense(
    DeleteSharedExpense event,
    Emitter<SharedExpenseState> emit,
  ) async {
    emit(const SharedExpenseState.loading());

    try {
      await _repository.deleteSharedExpense(event.expense);
      emit(const SharedExpenseState.deleted());
    } catch (e) {
      emit(const SharedExpenseState.error());
      print('Error al eliminar SharedExpense ❌: $e');
    }
  }

  Future<void> _onUpdateSharedExpense(
    UpdateSharedExpense event,
    Emitter<SharedExpenseState> emit,
  ) async {
    emit(const SharedExpenseState.loading());

    try {
      await _repository.updateSharedExpense(event.expense);
      emit(const SharedExpenseState.updated());
    } catch (e) {
      emit(const SharedExpenseState.error());
      print('Error al actualizar SharedExpense ❌: $e');
    }
  }
}
