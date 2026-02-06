part of 'personal_expense_payment_bloc.dart';

enum PersonalExpensePaymentStatus { initial, loading, success, error }

class PersonalExpensePaymentState extends Equatable {
  final PersonalExpensePaymentStatus status;
  final List<PersonalExpensePayment> payments;
  final String? errorMessage;

  const PersonalExpensePaymentState({
    this.status = PersonalExpensePaymentStatus.initial,
    this.payments = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, payments, errorMessage];

  PersonalExpensePaymentState copyWith({
    PersonalExpensePaymentStatus? status,
    List<PersonalExpensePayment>? payments,
    String? errorMessage,
  }) {
    return PersonalExpensePaymentState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
