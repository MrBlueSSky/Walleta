import 'package:equatable/equatable.dart';
import 'package:walleta/models/personal_expense.dart';

abstract class PersonalExpenseEvent extends Equatable {
  const PersonalExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar gastos personales
class LoadPersonalExpenses extends PersonalExpenseEvent {
  final String userId;

  const LoadPersonalExpenses(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Crear nuevo gasto
class AddPersonalExpense extends PersonalExpenseEvent {
  final PersonalExpense expense;
  final String userId;

  const AddPersonalExpense({required this.expense, required this.userId});

  @override
  List<Object?> get props => [expense, userId];
}

/// Actualizar gasto existente
class UpdatePersonalExpense extends PersonalExpenseEvent {
  final PersonalExpense expense;

  const UpdatePersonalExpense({required this.expense});

  @override
  List<Object?> get props => [expense];
}

/// Eliminar gasto
class DeletePersonalExpense extends PersonalExpenseEvent {
  final String expenseId;

  const DeletePersonalExpense(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

/// Registrar pago en gasto
class PayPersonalExpense extends PersonalExpenseEvent {
  final String expenseId;
  final double amount;

  const PayPersonalExpense({required this.expenseId, required this.amount});

  @override
  List<Object?> get props => [expenseId, amount];
}

/// Filtrar gastos por categoría
class FilterPersonalExpensesByCategory extends PersonalExpenseEvent {
  final String category;

  const FilterPersonalExpensesByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Filtrar gastos por estado
class FilterPersonalExpensesByStatus extends PersonalExpenseEvent {
  final String status;

  const FilterPersonalExpensesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Limpiar filtros
class ClearPersonalExpenseFilters extends PersonalExpenseEvent {}
