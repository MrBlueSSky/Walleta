import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/income/bloc/incomes_event.dart';
import 'package:walleta/blocs/income/bloc/incomes_state.dart';
import 'package:walleta/repository/income/income_repository.dart';

//!Luegooo le cambio el nombre a PersonalIncomesBloc, PersonalIncomesEvent, etc.

class IncomesBloc extends Bloc<IncomesEvent, IncomesState> {
  final IncomesRepository _repository;
  String? _currentUserId; // Guardar el userId actual

  IncomesBloc({required IncomesRepository repository})
    : _repository = repository,
      super(const IncomesState.initial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<AddIncomes>(_onAddIncomes);
    on<UpdateIncomes>(_onUpdateIncomes);
    on<DeleteIncomes>(_onDeleteIncomes);
    on<PayIncomes>(_onPayIncomes);
    // on<FilterIncomingsByCategory>(_onFilterByCategory);
    // on<FilterIncomingsByStatus>(_onFilterByStatus);
    // on<ClearIncomingFilters>(_onClearFilters);
  }

  Future<void> _onLoadIncomes(
    LoadIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    _currentUserId = event.userId; // Guardar userId
    emit(const IncomesState.loading());

    try {
      final incomes = await _repository.fetchIncomes(event.userId);

      print(
        'Incomes cargados exitosamente ✅: ${incomes.length} ingresos encontrados para userId: ${event.userId}',
      );

      emit(IncomesState.success(incomes));
    } catch (e) {
      emit(IncomesState.error('Error al cargar ingresos'));
      print('Error al cargar Incomings ❌: $e');
    }
  }

  Future<void> _onAddIncomes(
    AddIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    emit(const IncomesState.loading());

    try {
      await _repository.addIncoming(event.income, event.userId);

      // Recargar con el userId actual
      if (_currentUserId != null) {
        final incomes = await _repository.fetchIncomes(_currentUserId!);
        emit(IncomesState.success(incomes));
      } else {
        emit(const IncomesState.updated());
      }
    } catch (e) {
      emit(IncomesState.error('Error al agregar ingreso'));
      print('Error al agregar Incomes ❌: $e');
    }
  }

  Future<void> _onUpdateIncomes(
    UpdateIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    // Mantener el estado actual mientras se actualiza
    final currentState = state;

    try {
      // 1. Actualizar en el repositorio
      await _repository.updateIncoming(event.income);

      // 2. Si tenemos un userId guardado, recargar la lista
      if (_currentUserId != null) {
        final incomes = await _repository.fetchIncomes(_currentUserId!);
        // Mantener filtros si existen
        // if (state.filterCategory != null || state.filterStatus != null) {
        //   final filtered = _applyFilters(
        //     incomes,
        //     state.filterCategory,
        //     state.filterStatus,
        //   );
        //   emit(
        //     state.copyWith(
        //       status: IncomingStateStatus.success,
        //       incomings: incomings,
        //       filteredIncomings: filtered,
        //     ),
        //   );
        // } else {
        emit(IncomesState.success(incomes));
        // }
      } else {
        emit(const IncomesState.updated());
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          status: IncomesStateStatus.error,
          errorMessage: 'Error al actualizar ingreso',
        ),
      );
      print('Error al actualizar Incomes ❌: $e');
    }
  }

  Future<void> _onDeleteIncomes(
    DeleteIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    emit(const IncomesState.loading());

    try {
      await _repository.deleteIncoming(event.incomesId);

      // Recargar si tenemos userId
      if (_currentUserId != null) {
        final incomes = await _repository.fetchIncomes(_currentUserId!);
        emit(IncomesState.success(incomes));
      } else {
        emit(const IncomesState.deleted());
      }
    } catch (e) {
      emit(IncomesState.error('Error al eliminar ingreso'));
      print('Error al eliminar Incomes ❌: $e');
    }
  }

  Future<void> _onPayIncomes(
    PayIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    final currentState = state;

    try {
      await _repository.addPayment(event.incomingId, event.amount);

      // Recargar si tenemos userId
      if (_currentUserId != null) {
        final incomings = await _repository.fetchIncomes(_currentUserId!);
        // Mantener filtros si existen
        // if (state.filterCategory != null || state.filterStatus != null) {
        //   final filtered = _applyFilters(
        //     incomings,
        //     state.filterCategory,
        //     state.filterStatus,
        //   );
        //   emit(
        //     state.copyWith(
        //       status: IncomingStateStatus.success,
        //       incomings: incomings,
        //       filteredIncomings: filtered,
        //     ),
        //   );
        // } else {
        emit(IncomesState.success(incomings));
        // }
      }
    } catch (e) {
      emit(
        currentState.copyWith(
          status: IncomesStateStatus.error,
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

  // void _onClearFilters(
  //   ClearPersonalExpenseFilters event,
  //   Emitter<PersonalExpenseState> emit,
  // ) {
  //   if (state.expenses.isNotEmpty) {
  //     emit(PersonalExpenseState.success(state.expenses));
  //   } else {
  //     emit(const PersonalExpenseState.initial());
  //   }
  // }

  // // Método helper para aplicar filtros
  // List<PersonalExpense> _applyFilters(
  //   List<PersonalExpense> expenses,
  //   String? category,
  //   String? status,
  // ) {
  //   return expenses.where((expense) {
  //     bool matchesCategory = true;
  //     bool matchesStatus = true;

  //     if (category != null && category.isNotEmpty) {
  //       matchesCategory =
  //           expense.category.toLowerCase() == category.toLowerCase();
  //     }

  //     if (status != null && status.isNotEmpty) {
  //       // Calcular estado basado en paid/total
  //       final calculatedStatus =
  //           expense.paid >= expense.total
  //               ? 'paid'
  //               : expense.paid > 0
  //               ? 'partially_paid'
  //               : 'pending';

  //       matchesStatus = calculatedStatus == status.toLowerCase();
  //     }

  //     return matchesCategory && matchesStatus;
  //   }).toList();
  // }
}
