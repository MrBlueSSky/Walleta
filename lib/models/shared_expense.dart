import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/appUser.dart';

class SharedExpense {
  final String? id;
  final String title;
  final double total;
  final double paid;
  final List<AppUser> participants; // Todos los participantes, incluido creador
  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final String? status;
  final DateTime? createdAt;
  final AppUser createdBy; // Referencia rápida al creador

  SharedExpense({
    this.id,
    required this.title,
    required this.total,
    required this.paid,
    required this.participants,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    this.status,
    this.createdAt,
    required this.createdBy,
  });

  factory SharedExpense.fromFirestore(String id, Map<String, dynamic> data) {
    // Convertir la lista de participantes de Map a AppUser
    final participantsList =
        List<Map<String, dynamic>>.from(
          data['participants'] ?? [],
        ).map((userData) => AppUser.fromFirestore(userData)).toList();

    return SharedExpense(
      id: id,
      title: data['title'] ?? '',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      paid: (data['paid'] as num?)?.toDouble() ?? 0.0,
      participants: participantsList,
      category: data['category'] ?? '',
      categoryIcon: IconData(
        data['categoryIcon'] ?? Icons.attach_money.codePoint,
        fontFamily: data['categoryFontFamily'],
      ),
      categoryColor: Color(data['categoryColor'] ?? Colors.blue.value),
      status: data['status'] ?? 'pending',
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      createdBy: AppUser.fromFirestore(data['createdBy'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'total': total,
      'paid': paid,
      'participants': participants.map((user) => _userToMap(user)).toList(),
      'category': category,
      'categoryIcon': categoryIcon.codePoint,
      'categoryFontFamily': categoryIcon.fontFamily,
      'categoryColor': categoryColor.value,
      'createdBy': _userToMap(createdBy),
      'status': status ?? 'pending',
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
    };
  }

  // Helper para convertir AppUser a Map (sin sharedExpenseIds)
  Map<String, dynamic> _userToMap(AppUser user) {
    return {
      'uid': user.uid,
      'username': user.username,
      'name': user.name,
      'surname': user.surname,
      'email': user.email,
      'phoneNumber': user.phoneNumber,
      'profilePictureUrl': user.profilePictureUrl,
      'isPremium': user.isPremium,
      'premiumUntil':
          user.premiumUntil != null
              ? Timestamp.fromDate(user.premiumUntil!)
              : null,
    };
  }

  /// Verificar si un usuario es participante
  bool isUserParticipant(String userId) {
    return participants.any((user) => user.uid == userId);
  }

  /// Verificar si el usuario es el creador
  bool isUserCreator(String userId) {
    return createdBy.uid == userId;
  }

  /// Obtener cantidad de participantes
  int get participantCount => participants.length;

  /// Obtener share por persona (división equitativa)
  double get amountPerPerson {
    if (participants.isEmpty) return 0;
    return total / participants.length;
  }
}
