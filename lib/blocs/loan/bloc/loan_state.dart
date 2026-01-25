import 'package:equatable/equatable.dart';
import 'package:walleta/models/loan.dart';

enum LoanStateStatus { initial, deleted, updated, success, loading, error }

class LoanState extends Equatable {
  final LoanStateStatus status;
  final List<Loan> loans;

  const LoanState({
    this.status = LoanStateStatus.initial,
    this.loans = const [],
  });

  const LoanState.initial() : this(status: LoanStateStatus.initial);

  const LoanState.deleted() : this(status: LoanStateStatus.deleted);

  const LoanState.updated() : this(status: LoanStateStatus.updated);

  const LoanState.success(List<Loan> loans)
    : this(status: LoanStateStatus.success, loans: loans);

  const LoanState.loading() : this(status: LoanStateStatus.loading);

  const LoanState.error() : this(status: LoanStateStatus.error);

  @override
  List<Object?> get props => [status, loans];
}
