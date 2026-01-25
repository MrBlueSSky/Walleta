import 'package:bloc/bloc.dart';
import 'package:walleta/blocs/saving/bloc/saving_event.dart';
import 'package:walleta/blocs/saving/bloc/saving_state.dart';
import 'package:walleta/repository/saving/saving_repository.dart';

class SavingBloc extends Bloc<SavingEvent, SavingState> {
  final SavingGoalRepository _repository;
  String? _currentUserId;

  SavingBloc({required SavingGoalRepository repository})
      : _repository = repository,
        super(const SavingState.initial()) {
    on<LoadSavingGoals>(_onLoad);
    on<AddSavingGoal>(_onAdd);
    on<UpdateSavingGoal>(_onUpdate);
    on<DeleteSavingGoal>(_onDelete);
    on<AddMoneyToSavingGoal>(_onAddMoney);
  }

  Future<void> _onLoad(
    LoadSavingGoals event,
    Emitter<SavingState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(const SavingState.loading());

    try {
      final goals =
          await _repository.fetchSavingGoals(event.userId);
      emit(SavingState.success(goals));
    } catch (e) {
      emit(const SavingState.error());
      print('Error al cargar SavingGoals ❌: $e');
    }
  }

  Future<void> _onAdd(
    AddSavingGoal event,
    Emitter<SavingState> emit,
  ) async {
    emit(const SavingState.loading());

    try {
      await _repository.addSavingGoal(
        event.goal,
        event.userId,
      );

      final goals =
          await _repository.fetchSavingGoals(event.userId);
      emit(SavingState.success(goals));
    } catch (e) {
      emit(const SavingState.error());
      print('Error al crear SavingGoal ❌: $e');
    }
  }

  Future<void> _onUpdate(
    UpdateSavingGoal event,
    Emitter<SavingState> emit,
  ) async {
    try {
      await _repository.updateSavingGoal(
        event.goalId,
        event.goal,
      );

      if (_currentUserId != null) {
        final goals =
            await _repository.fetchSavingGoals(_currentUserId!);
        emit(SavingState.success(goals));
      } else {
        emit(const SavingState.updated());
      }
    } catch (e) {
      emit(const SavingState.error());
      print('Error al actualizar SavingGoal ❌: $e');
    }
  }

  Future<void> _onAddMoney(
    AddMoneyToSavingGoal event,
    Emitter<SavingState> emit,
  ) async {
    try {
      await _repository.addMoneyToGoal(
        event.goalId,
        event.amount,
      );

      if (_currentUserId != null) {
        final goals =
            await _repository.fetchSavingGoals(_currentUserId!);
        emit(SavingState.success(goals));
      }
    } catch (e) {
      emit(const SavingState.error());
      print('Error al abonar SavingGoal ❌: $e');
    }
  }

  Future<void> _onDelete(
    DeleteSavingGoal event,
    Emitter<SavingState> emit,
  ) async {
    emit(const SavingState.loading());

    try {
      await _repository.deleteSavingGoal(event.goalId);

      if (_currentUserId != null) {
        final goals =
            await _repository.fetchSavingGoals(_currentUserId!);
        emit(SavingState.success(goals));
      } else {
        emit(const SavingState.deleted());
      }
    } catch (e) {
      emit(const SavingState.error());
      print('Error al eliminar SavingGoal ❌: $e');
    }
  }
}
