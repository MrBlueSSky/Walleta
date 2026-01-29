// Clase para unificar todos los movimientos
import 'dart:ui';

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final bool isOutgoing; // true = salida, false = entrada
  final String description;
  final String otherPersonName;
  final TransactionType type;
  final Color? color;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.isOutgoing,
    required this.description,
    required this.otherPersonName,
    required this.type,
    this.color,
  });
}

enum TransactionType {
  payment, // Pago realizado/recibido
  loanCreated, // Préstamo creado
}
