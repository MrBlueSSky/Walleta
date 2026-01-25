import 'package:equatable/equatable.dart';
import 'package:walleta/models/savings.dart';

abstract class SavingEvent extends Equatable {
  const SavingEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar metas de ahorro
class LoadSavingGoals extends SavingEvent {
  final String userId;

  const LoadSavingGoals(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Crear meta de ahorro
class AddSavingGoal extends SavingEvent {
  final SavingGoal goal;
  final String userId;

  const AddSavingGoal({
    required this.goal,
    required this.userId,
  });

  @override
  List<Object?> get props => [goal, userId];
}

/// Actualizar meta
class UpdateSavingGoal extends SavingEvent {
  final String goalId;
  final SavingGoal goal;

  const UpdateSavingGoal({
    required this.goalId,
    required this.goal,
  });

  @override
  List<Object?> get props => [goalId, goal];
}

/// Eliminar meta
class DeleteSavingGoal extends SavingEvent {
  final String goalId;

  const DeleteSavingGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

/// Abonar dinero
class AddMoneyToSavingGoal extends SavingEvent {
  final String goalId;
  final double amount;

  const AddMoneyToSavingGoal({
    required this.goalId,
    required this.amount,
  });

  @override
  List<Object?> get props => [goalId, amount];
}
