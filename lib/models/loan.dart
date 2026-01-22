import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/appUser.dart';

enum LoanType { iOwe, owedToMe }

enum LoanStatus { pendiente, caduco, parcial, pagado }

enum LoanRole {
  lender, // El que prestó
  borrower, // El que debe
}

class Loan extends Equatable {
  final String id;

  /// Usuarios involucrados
  final AppUser lenderUserId;
  final AppUser borrowerUserId;

  final String description;
  final double amount;
  final double paidAmount;
  final DateTime dueDate;
  final DateTime createdAt; // ✅ Agregar este campo

  final LoanStatus status;

  /// Metadatos UI
  final Color color;

  const Loan({
    required this.id,
    required this.lenderUserId,
    required this.borrowerUserId,
    required this.description,
    required this.amount,
    required this.paidAmount,
    required this.dueDate,
    required this.status,
    required this.color,
    required this.createdAt, // ✅ Agregar al constructor
  }) : assert(amount >= 0, 'Amount cannot be negative'),
       assert(paidAmount >= 0, 'Paid amount cannot be negative'),
       assert(paidAmount <= amount, 'Paid amount cannot exceed total amount');

  /// 🔥 Factory para Firestore
  factory Loan.fromMap(String id, Map<String, dynamic> map) {
    return Loan(
      id: id,
      lenderUserId: AppUser(
        uid: map['lenderUserId'],
        name: map['lenderName'] ?? '',
        surname: map['lenderSurname'] ?? '',
        email: map['lenderEmail'] ?? '',
        username: map['lenderUsername'] ?? '',
        phoneNumber: '',
        profilePictureUrl: '',
      ),
      borrowerUserId: AppUser(
        uid: map['borrowerUserId'],
        name: map['borrowerName'] ?? '',
        surname: map['borrowerSurname'] ?? '',
        email: map['borrowerEmail'] ?? '',
        username: map['borrowerUsername'] ?? '',
        phoneNumber: '',
        profilePictureUrl: '',
      ),
      description: map['description'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num).toDouble(),
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LoanStatus.pendiente,
      ),
      color: Color(map['color'] ?? 0xFF000000),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  LoanRole roleFor(AppUser user) {
    if (user.uid == lenderUserId.uid) return LoanRole.lender;
    return LoanRole.borrower;
  }

  double get progress =>
      amount == 0.0 ? 0.0 : (paidAmount / amount).clamp(0.0, 1.0).toDouble();

  @override
  List<Object?> get props => [
    id,
    lenderUserId,
    borrowerUserId,
    description,
    amount,
    paidAmount,
    dueDate,
    status,
    color,
  ];
}
