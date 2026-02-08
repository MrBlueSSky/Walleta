import 'package:equatable/equatable.dart';
import 'package:walleta/models/income.dart';

enum IncomesStateStatus {
  initial,
  deleted,
  updated,
  success,
  loading,
  error,
  filtered,
}

class IncomesState extends Equatable {
  final IncomesStateStatus status;
  final List<Incomes> incomes;
  final List<Incomes> filteredIncomes;
  final String? filterCategory;
  final String? filterStatus;
  final String? errorMessage;

  const IncomesState({
    this.status = IncomesStateStatus.initial,
    this.incomes = const [],
    this.filteredIncomes = const [],
    this.filterCategory,
    this.filterStatus,
    this.errorMessage,
  });

  // Propiedades calculadas
  double get totalIncomes =>
      incomes.fold(0, (sum, income) => sum + income.total);
  double get totalPaid => incomes.fold(0, (sum, income) => sum + income.paid);
  double get totalPending => totalIncomes - totalPaid;

  // Getters para mostrar la lista actual (filtrada o completa)
  List<Incomes> get displayIncomes {
    if (filteredIncomes.isNotEmpty) return filteredIncomes;
    return incomes;
  }

  // Constructor factories para diferentes estados
  const IncomesState.initial() : this(status: IncomesStateStatus.initial);

  const IncomesState.deleted() : this(status: IncomesStateStatus.deleted);

  const IncomesState.updated() : this(status: IncomesStateStatus.updated);

  const IncomesState.success(List<Incomes> incomes)
    : this(status: IncomesStateStatus.success, incomes: incomes);

  const IncomesState.loading() : this(status: IncomesStateStatus.loading);

  const IncomesState.error([String? message])
    : this(status: IncomesStateStatus.error, errorMessage: message);

  const IncomesState.filtered({
    required List<Incomes> filteredIncomess,
    String? category,
    String? status,
  }) : this(
         status: IncomesStateStatus.filtered,
         filteredIncomes: filteredIncomess,
         filterCategory: category,
         filterStatus: status,
       );

  // Método para copiar con nuevos valores
  IncomesState copyWith({
    IncomesStateStatus? status,
    List<Incomes>? Incomess,
    List<Incomes>? filteredIncomess,
    String? filterCategory,
    String? filterStatus,
    String? errorMessage,
  }) {
    return IncomesState(
      status: status ?? this.status,
      incomes: Incomess ?? this.incomes,
      filteredIncomes: filteredIncomess ?? this.filteredIncomes,
      filterCategory: filterCategory ?? this.filterCategory,
      filterStatus: filterStatus ?? this.filterStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    incomes,
    filteredIncomes,
    filterCategory,
    filterStatus,
    errorMessage,
  ];
}
