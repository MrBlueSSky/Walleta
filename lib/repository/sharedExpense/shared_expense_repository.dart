// shared_expense_repository.dart - MODIFICA ESTE ARCHIVO

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/models/shared_expense.dart';

class SharedExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 👉 MÉTODO QUE EL BLoC ESPERA (fetchSharedExpenses)
  Future<List<SharedExpense>> fetchSharedExpenses(String userId) async {
    try {
      // 1. Obtener el usuario con sus sharedExpenseIds
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final user = AppUser.fromFirestore(userDoc.data()!);

      // Si no tiene gastos, retornar vacío
      if (user.sharedExpenseIds.isEmpty) return [];

      // 2. Obtener todos los gastos en UNA consulta
      final expensesSnapshot =
          await _firestore
              .collection('shared_expenses')
              .where(FieldPath.documentId, whereIn: user.sharedExpenseIds)
              .get();

      return expensesSnapshot.docs
          .map((doc) => SharedExpense.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error obteniendo gastos: $e');
      return [];
    }
  }

  /// 👉 MÉTODO QUE EL BLoC ESPERA (addSharedExpense)
  Future<void> addSharedExpense({
    required String userId, // Este es el ID del creador
    required SharedExpense expense,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Crear el documento del gasto
      final expenseRef = _firestore.collection('shared_expenses').doc();
      final expenseData = {
        ...expense.toFirestore(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      batch.set(expenseRef, expenseData);

      // 2. Actualizar sharedExpenseIds en TODOS los participantes
      for (final user in expense.participants) {
        final userRef = _firestore.collection('users').doc(user.uid);

        // Agregar el nuevo expenseId a la lista existente
        batch.update(userRef, {
          'sharedExpenseIds': FieldValue.arrayUnion([expenseRef.id]),
        });
      }

      await batch.commit();
      print('✅ Gasto creado con ${expense.participants.length} participantes');
    } catch (e) {
      print('❌ Error creando gasto: $e');
      rethrow;
    }
  }

  /// 👉 MÉTODO QUE EL BLoC ESPERA (updateSharedExpense)
  Future<void> updateSharedExpense(SharedExpense expense) async {
    try {
      if (expense.id == null) throw Exception('Expense ID is null');

      await _firestore
          .collection('shared_expenses')
          .doc(expense.id)
          .update(expense.toFirestore());

      print('✅ Gasto actualizado correctamente');
    } catch (e) {
      print('❌ Error actualizando gasto: $e');
      rethrow;
    }
  }

  /// 👉 MÉTODO QUE EL BLoC ESPERA (deleteSharedExpense)
  Future<void> deleteSharedExpense(
    SharedExpense expense,
    String currentUserId, // 👈 Necesitamos el userId del usuario actual
  ) async {
    try {
      // 1. Verificar permisos (solo el creador puede eliminar)
      if (expense.createdBy.uid != currentUserId) {
        throw Exception('Solo el organizador puede eliminar este gasto');
      }

      // 2. Eliminar con batch
      final batch = _firestore.batch();

      // Eliminar el gasto
      batch.delete(_firestore.collection('shared_expenses').doc(expense.id));

      // Remover expenseId de todos los participantes
      for (final user in expense.participants) {
        final userRef = _firestore.collection('users').doc(user.uid);
        batch.update(userRef, {
          'sharedExpenseIds': FieldValue.arrayRemove([expense.id]),
        });
      }

      await batch.commit();
      print('✅ Gasto eliminado correctamente');
    } catch (e) {
      print('❌ Error eliminando gasto: $e');
      rethrow;
    }
  }

  /// Método auxiliar para el repositorio nuevo (opcional)
  Future<String> createSharedExpense({
    required String title,
    required double total,
    required List<AppUser> otherParticipants,
    required AppUser currentUser,
    required String category,
    required IconData icon,
    required Color color,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Crear lista completa de participantes (creador + otros)
      final allParticipants = [currentUser, ...otherParticipants];

      // 2. Crear el SharedExpense
      final expense = SharedExpense(
        title: title,
        total: total,
        paid: total,
        participants: allParticipants,
        category: category,
        categoryIcon: icon,
        categoryColor: color,
        createdBy: currentUser,
      );

      // 3. Crear el documento del gasto
      final expenseRef = _firestore.collection('shared_expenses').doc();
      batch.set(expenseRef, {
        ...expense.toFirestore(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Actualizar sharedExpenseIds en TODOS los participantes
      for (final user in allParticipants) {
        final userRef = _firestore.collection('users').doc(user.uid);
        batch.update(userRef, {
          'sharedExpenseIds': FieldValue.arrayUnion([expenseRef.id]),
        });
      }

      await batch.commit();
      print('✅ Gasto creado con ${allParticipants.length} participantes');

      return expenseRef.id;
    } catch (e) {
      print('❌ Error creando gasto: $e');
      rethrow;
    }
  }

  /// Stream en tiempo real de gastos del usuario
  Stream<List<SharedExpense>> streamUserSharedExpenses(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((
      userSnapshot,
    ) async {
      if (!userSnapshot.exists) return [];

      final user = AppUser.fromFirestore(userSnapshot.data()!);

      if (user.sharedExpenseIds.isEmpty) return [];

      final expensesSnapshot =
          await _firestore
              .collection('shared_expenses')
              .where(FieldPath.documentId, whereIn: user.sharedExpenseIds)
              .get();

      return expensesSnapshot.docs
          .map((doc) => SharedExpense.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  /// Buscar usuarios por username para agregar como participantes
  Future<List<AppUser>> searchUsersByUsername(String query) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('username', isGreaterThanOrEqualTo: query)
              .where('username', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(10)
              .get();

      return snapshot.docs
          .map((doc) => AppUser.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error buscando usuarios: $e');
      return [];
    }
  }

  /// Helper para convertir AppUser a Map básico (sin sharedExpenseIds)
  Map<String, dynamic> _userToBasicMap(AppUser user) {
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
}
