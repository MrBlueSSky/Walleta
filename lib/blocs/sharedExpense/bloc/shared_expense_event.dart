import 'package:walleta/models/appUser.dart';
import 'package:walleta/models/shared_expense.dart';

abstract class SharedExpenseEvent {}

class LoadSharedExpenses extends SharedExpenseEvent {
  final String userId;

  LoadSharedExpenses({required this.userId});
}

class AddSharedExpense extends SharedExpenseEvent {
  final String userId;
  final SharedExpense expense;

  AddSharedExpense({
    required this.userId,
    required this.expense,
    required AppUser currentUser,
  });
}

class UpdateSharedExpense extends SharedExpenseEvent {
  final SharedExpense expense;

  UpdateSharedExpense({required this.expense});
}

class DeleteSharedExpense extends SharedExpenseEvent {
  final SharedExpense expense;

  DeleteSharedExpense(this.expense);
}
