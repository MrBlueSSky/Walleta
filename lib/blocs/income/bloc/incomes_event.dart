import 'package:equatable/equatable.dart';
import 'package:walleta/models/income.dart';

abstract class IncomesEvent extends Equatable {
  const IncomesEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomesEvent {
  final String userId;

  const LoadIncomes(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddIncomes extends IncomesEvent {
  final Incomes income;
  final String userId;

  const AddIncomes({required this.income, required this.userId});
  @override
  List<Object?> get props => [income, userId];
}

class UpdateIncomes extends IncomesEvent {
  final Incomes income;

  const UpdateIncomes({required this.income});

  @override
  List<Object?> get props => [income];
}

/// Eliminar gasto
class DeleteIncomes extends IncomesEvent {
  final String incomesId;

  const DeleteIncomes(this.incomesId);

  @override
  List<Object?> get props => [incomesId];
}

class PayIncomes extends IncomesEvent {
  final String incomingId;
  final double amount;

  const PayIncomes({required this.incomingId, required this.amount});
  @override
  List<Object?> get props => [incomingId, amount];
}

// /// Filtrar gastos por categoría
// class FilterPersonalExpensesByCategory extends PersonalExpenseEvent {
//   final String category;

//   const FilterPersonalExpensesByCategory(this.category);

//   @override
//   List<Object?> get props => [category];
// }

// /// Filtrar gastos por estado
// class FilterPersonalExpensesByStatus extends PersonalExpenseEvent {
//   final String status;

//   const FilterPersonalExpensesByStatus(this.status);

//   @override
//   List<Object?> get props => [status];
// }

// /// Limpiar filtros
// class ClearPersonalExpenseFilters extends PersonalExpenseEvent {}
