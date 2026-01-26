import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_event.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_state.dart';
import 'package:walleta/models/personal_expense.dart';
import 'package:walleta/repository/personalExpense/personal_expense.dart';

class PersonalExpenseBloc
    extends Bloc<PersonalExpenseEvent, PersonalExpenseState> {
  final PersonalExpenseRepository _repository;
  String? _currentUserId; // Guardar el userId actual

  PersonalExpenseBloc({required PersonalExpenseRepository repository})
    : _repository = repository,
      super(const PersonalExpenseState.initial()) {
    on<LoadPersonalExpenses>(_onLoadPersonalExpenses);
    on<AddPersonalExpense>(_onAddPersonalExpense);
    on<UpdatePersonalExpense>(_onUpdatePersonalExpense);
    on<DeletePersonalExpense>(_onDeletePersonalExpense);
    on<PayPersonalExpense>(_onPayPersonalExpense);
    // on<FilterPersonalExpensesByCategory>(_onFilterByCategory);
    // on<FilterPersonalExpensesByStatus>(_onFilterByStatus);
    on<ClearPersonalExpenseFilters>(_onClearFilters);
  }

  Future<void> _onLoadPersonalExpenses(
    LoadPersonalExpenses event,
    Emitter<PersonalExpenseState> emit,
  ) async {
    _currentUserId = event.userId; // Guardar userId
    emit(const PersonalExpenseState.loading());

    try {
      final expenses = await _repository.fetchExpenses(event.userId);
      emit(PersonalExpenseState.success(expenses));
    } catch (e) {
      emit(PersonalExpenseState.error('Error al cargar gastos'));
      print('Error al cargar PersonalExpenses ❌: $e');
    }
  }

  Future<void> _onAddPersonalExpense(
    AddPersonalExpense event,
    Emitter<PersonalExpenseState> emit,
  ) async {
    emit(const PersonalExpenseState.loading());

    try {
      await _repository.addExpense(event.expense, event.userId);

      // Recargar con el userId actual
      if (_currentUserId != null) {
        final expenses = await _repository.fetchExpenses(_currentUserId!);
        emit(PersonalExpenseState.success(expenses));
      } else {
        emit(const PersonalExpenseState.updated());
      }
    } catch (e) {
      emit(PersonalExpenseState.error('Error al agregar gasto'));
      print('Error al agregar PersonalExpense ❌: $e');
    }
  }

  Future<void> _onUpdatePersonalExpense(
    UpdatePersonalExpense event,
    Emitter<PersonalExpenseState> emit,
  ) async {
    // Mantener el estado actual mientras se actualiza
    final currentState = state;

    try {
      // 1. Actualizar en el repositorio
      await _repository.updateExpense(event.expense);

      // 2. Si tenemos un userId guardado, recargar la lista
      if (_currentUserId != null) {
        final expenses = await _repository.fetchExpenses(_currentUserId!);

        // Mantener filtros si existen
        if (state.filterCategory != null || state.filterStatus != null) {
          final filtered = _applyFilters(
            expenses,
            state.filterCategory,
            state.filterStatus,
          );
          emit(
            state.copyWith(
              status: PersonalExpenseStateStatus.success,
              expenses: expenses,
              filteredExpenses: filtered,
            ),
          );
        } else {
          emit(PersonalExpenseState.success(expenses));
        }
      } else {
        emit(const PersonalExpenseState.updated());
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          status: PersonalExpenseStateStatus.error,
          errorMessage: 'Error al actualizar gasto',
        ),
      );
      print('Error al actualizar PersonalExpense ❌: $e');
    }
  }

  Future<void> _onDeletePersonalExpense(
    DeletePersonalExpense event,
    Emitter<PersonalExpenseState> emit,
  ) async {
    emit(const PersonalExpenseState.loading());

    try {
      await _repository.deleteExpense(event.expenseId);

      // Recargar si tenemos userId
      if (_currentUserId != null) {
        final expenses = await _repository.fetchExpenses(_currentUserId!);
        emit(PersonalExpenseState.success(expenses));
      } else {
        emit(const PersonalExpenseState.deleted());
      }
    } catch (e) {
      emit(PersonalExpenseState.error('Error al eliminar gasto'));
      print('Error al eliminar PersonalExpense ❌: $e');
    }
  }

  Future<void> _onPayPersonalExpense(
    PayPersonalExpense event,
    Emitter<PersonalExpenseState> emit,
  ) async {
    final currentState = state;

    try {
      await _repository.addPayment(event.expenseId, event.amount);

      // Recargar si tenemos userId
      if (_currentUserId != null) {
        final expenses = await _repository.fetchExpenses(_currentUserId!);

        // Mantener filtros si existen
        if (state.filterCategory != null || state.filterStatus != null) {
          final filtered = _applyFilters(
            expenses,
            state.filterCategory,
            state.filterStatus,
          );
          emit(
            state.copyWith(
              status: PersonalExpenseStateStatus.success,
              expenses: expenses,
              filteredExpenses: filtered,
            ),
          );
        } else {
          emit(PersonalExpenseState.success(expenses));
        }
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          status: PersonalExpenseStateStatus.error,
          errorMessage: 'Error al registrar pago',
        ),
      );
      print('Error al registrar pago ❌: $e');
    }
  }

  // void _onFilterByCategory(
  //   FilterPersonalExpensesByCategory event,
  //   Emitter<PersonalExpenseState> emit,
  // ) {
  //   if (event.category.isEmpty) {
  //     _onClearFilters(event, emit);
  //     return;
  //   }

  //   final filtered = _applyFilters(
  //     state.expenses,
  //     event.category,
  //     state.filterStatus,
  //   );
  //   emit(
  //     PersonalExpenseState.filtered(
  //       filteredExpenses: filtered,
  //       category: event.category,
  //       status: state.filterStatus,
  //     ),
  //   );
  // }

  // void _onFilterByStatus(
  //   FilterPersonalExpensesByStatus event,
  //   Emitter<PersonalExpenseState> emit,
  // ) {
  //   if (event.status.isEmpty) {
  //     _onClearFilters(event, emit);
  //     return;
  //   }

  //   final filtered = _applyFilters(
  //     state.expenses,
  //     state.filterCategory,
  //     event.status,
  //   );
  //   emit(
  //     PersonalExpenseState.filtered(
  //       filteredExpenses: filtered,
  //       category: state.filterCategory,
  //       status: event.status,
  //     ),
  //   );
  // }

  void _onClearFilters(
    ClearPersonalExpenseFilters event,
    Emitter<PersonalExpenseState> emit,
  ) {
    if (state.expenses.isNotEmpty) {
      emit(PersonalExpenseState.success(state.expenses));
    } else {
      emit(const PersonalExpenseState.initial());
    }
  }

  // Método helper para aplicar filtros
  List<PersonalExpense> _applyFilters(
    List<PersonalExpense> expenses,
    String? category,
    String? status,
  ) {
    return expenses.where((expense) {
      bool matchesCategory = true;
      bool matchesStatus = true;

      if (category != null && category.isNotEmpty) {
        matchesCategory =
            expense.category.toLowerCase() == category.toLowerCase();
      }

      if (status != null && status.isNotEmpty) {
        // Calcular estado basado en paid/total
        final calculatedStatus =
            expense.paid >= expense.total
                ? 'paid'
                : expense.paid > 0
                ? 'partially_paid'
                : 'pending';

        matchesStatus = calculatedStatus == status.toLowerCase();
      }

      return matchesCategory && matchesStatus;
    }).toList();
  }
}
