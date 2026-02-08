// shared_expense_bloc.dart - MODIFICA ESTE ARCHIVO

import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_state.dart';
import 'package:walleta/repository/sharedExpense/shared_expense_repository.dart';

class SharedExpenseBloc extends Bloc<SharedExpenseEvent, SharedExpenseState> {
  final SharedExpenseRepository _repository;
  String? _currentUserId; // 👈 Guardar el userId actual //!Vrr luego

  SharedExpenseBloc({required SharedExpenseRepository sharedExpenseRepository})
    : _repository = sharedExpenseRepository,
      super(const SharedExpenseState.initial()) {
    on<LoadSharedExpenses>(_onLoadSharedExpenses);
    on<AddSharedExpense>(_onAddSharedExpense);
    on<DeleteSharedExpense>(_onDeleteSharedExpense);
    on<UpdateSharedExpense>(_onUpdateSharedExpense);
  }

  // 👉 Método para establecer el userId actual //!Luego veoooooooooo, si lo paso desde el incio a todos los blocs
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
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
      emit(const SharedExpenseState.error('Error al cargar SharedExpenses'));
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
        userId: event.userId, // 👈 Usar el userId del evento
        expense: event.expense,
      );

      final expenses = await _repository.fetchSharedExpenses(event.userId);

      emit(SharedExpenseState.success(expenses));
    } catch (e) {
      emit(const SharedExpenseState.error('Error al agregar SharedExpense'));
      print('Error al agregar SharedExpense ❌: $e');
    }
  }

  Future<void> _onDeleteSharedExpense(
    DeleteSharedExpense event,
    Emitter<SharedExpenseState> emit,
  ) async {
    emit(const SharedExpenseState.loading());

    try {
      // 👈 Necesitamos el userId actual para verificar permisos
      // if (_currentUserId == null) {
      //   throw Exception('Usuario no autenticado');
      // }

      await _repository.deleteSharedExpense(
        event.expense,
        event.currentUser.uid, // 👈 Pasar el userId actual
      );

      // Recargar la lista después de eliminar
      if (_currentUserId != null) {
        final expenses = await _repository.fetchSharedExpenses(_currentUserId!);
        emit(SharedExpenseState.success(expenses));
      } else {
        emit(const SharedExpenseState.deleted());
      }
    } catch (e) {
      emit(
        const SharedExpenseState.error(
          'Error al eliminar, no eres el organizador o hubo un problema',
        ),
      );
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
      emit(const SharedExpenseState.error('Error al actualizar SharedExpense'));
      print('Error al actualizar SharedExpense ❌: $e');
    }
  }
}
