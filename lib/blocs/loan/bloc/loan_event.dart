import 'package:equatable/equatable.dart';
import 'package:walleta/models/loan.dart';

abstract class LoanEvent extends Equatable {
  const LoanEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar préstamos (ej: desde backend)
class LoadLoans extends LoanEvent {
  final String userId;

  const LoadLoans(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Crear préstamo
class AddLoan extends LoanEvent {
  final Loan loan;

  const AddLoan(this.loan);

  @override
  List<Object?> get props => [loan];
}

/// Actualizar préstamo (estado, fecha, etc.)
class UpdateLoan extends LoanEvent {
  final Loan loan;

  const UpdateLoan({required this.loan});

  @override
  List<Object?> get props => [loan];
}

/// Eliminar préstamo
class DeleteLoan extends LoanEvent {
  final String loanId;

  const DeleteLoan(this.loanId);

  @override
  List<Object?> get props => [loanId];
}

/// Abonar dinero al préstamo
class PayLoan extends LoanEvent {
  final String loanId;
  final double amount;

  const PayLoan({required this.loanId, required this.amount});

  @override
  List<Object?> get props => [loanId, amount];
}
