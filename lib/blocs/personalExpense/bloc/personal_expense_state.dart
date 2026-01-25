import 'package:equatable/equatable.dart';
import 'package:walleta/models/personal_expense.dart';

enum PersonalExpenseStateStatus {
  initial,
  deleted,
  updated,
  success,
  loading,
  error,
  filtered,
}

class PersonalExpenseState extends Equatable {
  final PersonalExpenseStateStatus status;
  final List<PersonalExpense> expenses;
  final List<PersonalExpense> filteredExpenses;
  final String? filterCategory;
  final String? filterStatus;
  final String? errorMessage;

  const PersonalExpenseState({
    this.status = PersonalExpenseStateStatus.initial,
    this.expenses = const [],
    this.filteredExpenses = const [],
    this.filterCategory,
    this.filterStatus,
    this.errorMessage,
  });

  // Propiedades calculadas
  double get totalExpenses =>
      expenses.fold(0, (sum, expense) => sum + expense.total);
  double get totalPaid =>
      expenses.fold(0, (sum, expense) => sum + expense.paid);
  double get totalPending => totalExpenses - totalPaid;

  // Getters para mostrar la lista actual (filtrada o completa)
  List<PersonalExpense> get displayExpenses {
    if (filteredExpenses.isNotEmpty) return filteredExpenses;
    return expenses;
  }

  // Constructor factories para diferentes estados
  const PersonalExpenseState.initial()
    : this(status: PersonalExpenseStateStatus.initial);

  const PersonalExpenseState.deleted()
    : this(status: PersonalExpenseStateStatus.deleted);

  const PersonalExpenseState.updated()
    : this(status: PersonalExpenseStateStatus.updated);

  const PersonalExpenseState.success(List<PersonalExpense> expenses)
    : this(status: PersonalExpenseStateStatus.success, expenses: expenses);

  const PersonalExpenseState.loading()
    : this(status: PersonalExpenseStateStatus.loading);

  const PersonalExpenseState.error([String? message])
    : this(status: PersonalExpenseStateStatus.error, errorMessage: message);

  const PersonalExpenseState.filtered({
    required List<PersonalExpense> filteredExpenses,
    String? category,
    String? status,
  }) : this(
         status: PersonalExpenseStateStatus.filtered,
         filteredExpenses: filteredExpenses,
         filterCategory: category,
         filterStatus: status,
       );

  // Método para copiar con nuevos valores
  PersonalExpenseState copyWith({
    PersonalExpenseStateStatus? status,
    List<PersonalExpense>? expenses,
    List<PersonalExpense>? filteredExpenses,
    String? filterCategory,
    String? filterStatus,
    String? errorMessage,
  }) {
    return PersonalExpenseState(
      status: status ?? this.status,
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      filterCategory: filterCategory ?? this.filterCategory,
      filterStatus: filterStatus ?? this.filterStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    expenses,
    filteredExpenses,
    filterCategory,
    filterStatus,
    errorMessage,
  ];
}
