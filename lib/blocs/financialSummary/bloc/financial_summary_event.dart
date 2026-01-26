// blocs/financial_summary/financial_summary_event.dart
import 'package:equatable/equatable.dart';

abstract class FinancialSummaryEvent extends Equatable {
  const FinancialSummaryEvent();

  @override
  List<Object> get props => [];
}

class LoadFinancialSummary extends FinancialSummaryEvent {
  final String userId;

  const LoadFinancialSummary(this.userId);

  @override
  List<Object> get props => [userId];
}

class RefreshFinancialSummary extends FinancialSummaryEvent {
  final String userId;

  const RefreshFinancialSummary(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadFinancialSummaryByDateRange extends FinancialSummaryEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadFinancialSummaryByDateRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}
