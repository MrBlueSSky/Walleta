import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_event.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_state.dart';
import 'package:walleta/models/financial_summary.dart';
import 'package:walleta/repository/FinancialSummary/financial_summary_repository.dart';

class FinancialSummaryBloc
    extends Bloc<FinancialSummaryEvent, FinancialSummaryState> {
  final FinancialSummaryRepository _repository;

  FinancialSummaryBloc({required FinancialSummaryRepository repository})
    : _repository = repository,
      super(FinancialSummaryInitial()) {
    on<LoadFinancialSummary>(_onLoadFinancialSummary);
    on<RefreshFinancialSummary>(_onRefreshFinancialSummary);
    // on<LoadFinancialSummaryByDateRange>(_onLoadFinancialSummaryByDateRange);
  }

  Future<void> _onLoadFinancialSummary(
    LoadFinancialSummary event,
    Emitter<FinancialSummaryState> emit,
  ) async {
    emit(FinancialSummaryLoading());

    try {
      final result = await _repository.getFinancialSummary(event.userId);
      final summaries = result['summaries'] as List<FinancialSummary>;
      // final total = result['total'] as FinancialTotal;

      emit(
        FinancialSummaryLoaded(
          summaries: summaries,
          // total: total,
          userId: event.userId,
        ),
      );
    } catch (e) {
      emit(FinancialSummaryError('Error al cargar el resumen financiero: $e'));
      print('Error en FinancialSummaryBloc: $e');
    }
  }

  Future<void> _onRefreshFinancialSummary(
    RefreshFinancialSummary event,
    Emitter<FinancialSummaryState> emit,
  ) async {
    try {
      // Si ya estamos cargados, mantenemos los datos anteriores mientras se refresca
      if (state is FinancialSummaryLoaded) {
        final currentState = state as FinancialSummaryLoaded;
        emit(
          FinancialSummaryLoaded(
            summaries: currentState.summaries,
            // total: currentState.total,
            userId: currentState.userId,
          ),
        );
      }

      final result = await _repository.getFinancialSummary(event.userId);
      final summaries = result['summaries'] as List<FinancialSummary>;
      // final total = result['total'] as FinancialTotal;

      emit(
        FinancialSummaryLoaded(
          summaries: summaries,
          // total: total,
          userId: event.userId,
        ),
      );
    } catch (e) {
      emit(FinancialSummaryError('Error al refrescar el resumen: $e'));
    }
  }

  // Future<void> _onLoadFinancialSummaryByDateRange(
  //   LoadFinancialSummaryByDateRange event,
  //   Emitter<FinancialSummaryState> emit,
  // ) async {
  //   emit(FinancialSummaryLoading());

  //   try {
  //     final result = await _repository.getFinancialSummaryByDateRange(
  //       event.userId,
  //       startDate: event.startDate,
  //       endDate: event.endDate,
  //     );

  //     final summaries = result['summaries'] as List<FinancialSummary>;
  //     final total = result['total'] as FinancialTotal;

  //     emit(
  //       FinancialSummaryLoaded(
  //         summaries: summaries,
  //         total: total,
  //         userId: event.userId,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(FinancialSummaryError('Error al cargar resumen por fecha: $e'));
  //     print('Error en FinancialSummaryBloc (rango fechas): $e');
  //   }
  // }
}
