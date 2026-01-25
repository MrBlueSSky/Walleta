import 'package:equatable/equatable.dart';
import 'package:walleta/models/savings.dart';

enum SavingStateStatus { initial, loading, success, updated, deleted, error }

class SavingState extends Equatable {
  final SavingStateStatus status;
  final List<SavingGoal> goals;

  const SavingState({
    this.status = SavingStateStatus.initial,
    this.goals = const [],
  });

  const SavingState.initial()
      : this(status: SavingStateStatus.initial);

  const SavingState.loading()
      : this(status: SavingStateStatus.loading);

  const SavingState.success(List<SavingGoal> goals)
      : this(status: SavingStateStatus.success, goals: goals);

  const SavingState.updated()
      : this(status: SavingStateStatus.updated);

  const SavingState.deleted()
      : this(status: SavingStateStatus.deleted);

  const SavingState.error()
      : this(status: SavingStateStatus.error);

  @override
  List<Object?> get props => [status, goals];
}
