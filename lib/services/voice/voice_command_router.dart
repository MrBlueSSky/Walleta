// lib/services/voice_command_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/income/bloc/incomes_bloc.dart';
import 'package:walleta/blocs/income/bloc/incomes_event.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_event.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_event.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/models/income.dart';
import 'package:walleta/utils/formatters.dart';

import 'package:walleta/models/personal_expense.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/utils/category_mapper.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';

class VoiceCommandRouter {
  final BuildContext context;

  VoiceCommandRouter(this.context);

  // Método principal para procesar y ejecutar comandos
  Future<void> processAndExecute(Map<String, dynamic> result) async {
    final user = context.read<AuthenticationBloc>().state.user;

    if (result['success'] != true) {
      _showErrorMessage(result['error']?.toString() ?? 'Comando no procesado');
      return;
    }

    final data = result['data'];
    if (data == null) {
      _showErrorMessage('No se encontraron datos en el comando');
      return;
    }

    print("📍📍📍📍📍📍");
    print(data);

    final type = data['transaction_type']?.toString() ?? '';

    try {
      switch (type) {
        case 'personal_expense':
          await _handlePersonalExpense(data, user);
          break;
        case 'income':
          await _handleIncome(data, user);
          break;
        case 'shared_expenses':
        case 'split_bill':
          await _handleSharedExpense(data, user);
          break;
        // case 'payment_to_person':
        //   await _handlePaymentToPerson(data, user);
        //   break;
        // case 'loan':
        //   await _handleLoan(data, user);
        //   break;
        case 'loan':
          await _handleMoneyRequest(data);
          break;
        // case 'balance_check':
        //   await _handleBalanceCheck(data);
        //   break;
        // case 'budget_setting':
        //   await _handleBudgetSetting(data);
        //   break;
        // default:
        //   await _handleGenericTransaction(data);
      }

      _showSuccessMessage(_getSuccessMessage(type, data));
    } catch (e) {
      _showErrorMessage('Error ejecutando comando: $e');
    }
  }

  // ==================== MANEJADORES ESPECÍFICOS ====================

  Future<void> _handlePersonalExpense(
    Map<String, dynamic> data,
    AppUser user,
  ) async {
    final String rawCategory = data['category']?.toString() ?? 'otros';
    final String normalizedCategory = CategoryMapper.normalizeCategory(
      rawCategory,
    );

    final expense = PersonalExpense(
      title: data['title']?.toString() ?? 'Gasto personal',
      category: Formatters.capitalize(normalizedCategory),
      total: (data['amount'] as num?)?.toDouble() ?? 0.0,
      paid: data['paid'] ?? 0.0,
      categoryIcon: CategoryMapper.getIconForCategory(
        normalizedCategory,
      ), // Icono según categoría
      categoryColor: CategoryMapper.getColorForCategory(
        normalizedCategory,
      ), // Color según categoría
      date: DateTime.now(),
    );

    context.read<PersonalExpenseBloc>().add(
      AddPersonalExpense(userId: user.uid, expense: expense),
    );
  }

  Future<void> _handleIncome(Map<String, dynamic> data, AppUser user) async {
    final String rawCategory = data['category']?.toString() ?? 'otros';
    final String normalizedCategory = CategoryMapper.normalizeCategory(
      rawCategory,
    );
    final income = Incomes(
      title: data['title']?.toString() ?? 'Ingreso',
      category: Formatters.capitalize(normalizedCategory),
      date: DateTime.now(),
      total: data['amount'] != null ? (data['amount'] as num).toDouble() : 0.0,
      paid: data['paid'] ?? 0.0,
      categoryIcon: CategoryMapper.getIconForCategory(
        normalizedCategory,
      ), // Icono según categoría
      categoryColor: CategoryMapper.getColorForCategory(
        normalizedCategory,
      ), // Color según categoría
    );

    context.read<IncomesBloc>().add(
      AddIncomes(income: income, userId: user.uid),
    );
  }

  Future<void> _handleSharedExpense(
    Map<String, dynamic> data,
    AppUser user,
  ) async {
    final String rawCategory = data['category']?.toString() ?? 'otros';
    final String normalizedCategory = CategoryMapper.normalizeCategory(
      rawCategory,
    );

    final expense = SharedExpense(
      title: data['title']?.toString() ?? 'Gasto compartido',
      category: Formatters.capitalize(normalizedCategory),
      total: (data['amount'] as num?)?.toDouble() ?? 0.0,
      paid: data['paid'] ?? 0.0,
      createdBy: user,
      participants: [user], // Gasto personal, sin participantes
      categoryIcon: CategoryMapper.getIconForCategory(
        normalizedCategory,
      ), // Icono según categoría
      categoryColor: CategoryMapper.getColorForCategory(
        normalizedCategory,
      ), // Color según categoría
    );

    context.read<SharedExpenseBloc>().add(
      AddSharedExpense(userId: user.uid, expense: expense, currentUser: user),
    );
  }

  // Future<void> _handlePaymentToPerson(
  //   Map<String, dynamic> data,
  //   AppUser user,
  // ) async {
  //   final payment = Payment(
  //     userId: user.uid,
  //     date:
  //         data['date'] != null
  //             ? DateTime.parse(data['date'].toString())
  //             : DateTime.now(),

  //     amount: data['amount']?.toDouble() ?? 0.0,
  //   );

  //   context.read<PaymentBloc>().add(AddPayment(payment: payment));
  // }

  // Future<void> _handleLoan(Map<String, dynamic> data) async {
  //   final isGiven = data['transaction_type'] == 'loan_given';

  //   final loan = Loan(
  //     id: '',
  //     lenderUserId: null,
  //     borrowerUserId: null,
  //     description: data['description']?.toString() ?? '',
  //     amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
  //     paidAmount: 0.0,
  //     dueDate:
  //         data['due_date'] != null
  //             ? DateTime.parse(data['due_date'].toString())
  //             : null,
  //     status: LoanStatus.pendiente,
  //     color: Colors.blue,
  //     createdAt: DateTime.now(),
  //   );

  //   context.read<LoanBloc>().add(AddLoan(loan));
  // }

  Future<void> _handleMoneyRequest(Map<String, dynamic> data) async {
    // Para solicitudes de dinero, podrías crear una notificación o registro
    final request = {
      'title': data['title']?.toString() ?? 'Solicitud de pago',
      'description': data['description']?.toString() ?? '',
      'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
      'currency': data['currency']?.toString() ?? 'CRC',
      'person': data['target_person']?.toString(),
      'dueDate':
          data['due_date'] != null
              ? DateTime.parse(data['due_date'].toString())
              : null,
      'status': 'pending',
      'createdAt': DateTime.now(),
    };

    // Aquí podrías dispatchar un evento a un MoneyRequestBloc si lo tienes
    // O guardarlo directamente en Firestore
    _showInfoMessage('Solicitud de pago creada: ${request['title']}');
  }

  // ==================== MENSAJES ====================

  String _getSuccessMessage(String type, Map<String, dynamic> data) {
    final amount = data['amount'];
    final person = data['target_person'];
    final amountStr =
        amount != null ? ' de \$${(amount as num).toDouble()}' : '';

    switch (type) {
      case 'expense':
        return 'Gasto$amountStr registrado';
      case 'income':
        return 'Ingreso$amountStr registrado';
      case 'shared_expense':
        return 'Gasto compartido$amountStr registrado';
      case 'loan_given':
        return 'Préstamo$amountStr a $person registrado';
      case 'loan_received':
        return 'Préstamo$amountStr de $person registrado';
      case 'payment_to_person':
        return 'Pago$amountStr a $person registrado';
      case 'money_request':
        return 'Solicitud de pago$amountStr a $person creada';
      default:
        return 'Transacción registrada';
    }
  }

  void _showSuccessMessage(String message) {
    TopSnackBarOverlay.show(
      context: context,
      message: message,
      verticalOffset: 70.0,
      backgroundColor: Colors.green,
    );
  }

  void _showInfoMessage(String message) {
    TopSnackBarOverlay.show(
      context: context,
      message: message,
      verticalOffset: 70.0,
      backgroundColor: Colors.blue,
    );
  }

  void _showErrorMessage(String message) {
    TopSnackBarOverlay.show(
      context: context,
      message: message,
      verticalOffset: 70.0,
      backgroundColor: Colors.red,
    );
  }

  // ==================== MÉTODO DE FÁCIL USO ====================

  static Future<void> routeCommand(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    final router = VoiceCommandRouter(context);
    await router.processAndExecute(result);
  }
}
