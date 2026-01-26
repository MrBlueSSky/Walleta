// blocs/financial_summary/financial_summary_state.dart
import 'package:equatable/equatable.dart';
import 'package:walleta/models/financial_summary.dart';

abstract class FinancialSummaryState extends Equatable {
  const FinancialSummaryState();

  @override
  List<Object> get props => [];
}

class FinancialSummaryInitial extends FinancialSummaryState {}

class FinancialSummaryLoading extends FinancialSummaryState {}

class FinancialSummaryLoaded extends FinancialSummaryState {
  final List<FinancialSummary> summaries;
  // final FinancialTotal total;
  final String userId;

  const FinancialSummaryLoaded({
    required this.summaries,
    // required this.total,
    required this.userId,
  });

  @override
  List<Object> get props => [summaries, userId];

  // List<Object> get props => [summaries, total, userId];
}

class FinancialSummaryError extends FinancialSummaryState {
  final String message;

  const FinancialSummaryError(this.message);

  @override
  List<Object> get props => [message];
}
