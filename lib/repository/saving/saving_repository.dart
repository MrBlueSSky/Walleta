import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walleta/models/savings.dart';

class SavingGoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'saving_goals';

  SavingGoalRepository();

  /// =======================
  /// READ - Obtener metas
  /// =======================
  Future<List<SavingGoal>> fetchSavingGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('🎯 Fetched ${snapshot.docs.length} saving goals ✅');

      return snapshot.docs.map((doc) => SavingGoal.fromDocument(doc)).toList();
    } catch (e) {
      print('⚠️ No se pudieron cargar las metas, creando una inicial: $e');

      // Crear meta inicial si falla la consulta
      await initializeUserSavingGoal(userId);

      // Devolver la meta inicial
      return await fetchSavingGoalsWithoutOrder(userId);
    }
  }

  /// =======================
  /// READ - Obtener metas sin orderBy (para evitar fallo de índice)
  /// =======================
  Future<List<SavingGoal>> fetchSavingGoalsWithoutOrder(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => SavingGoal.fromDocument(doc)).toList();
  }

  /// =======================
  /// CREATE - Crear meta
  /// =======================
  Future<void> addSavingGoal(SavingGoal goal, String userId) async {
    try {
      await _firestore.collection(_collection).add(goal.toJson(userId));
      print('✅ SavingGoal creado para el usuario $userId');
    } catch (e) {
      print('Error al crear SavingGoal ❌: $e');
      rethrow;
    }
  }

  /// =======================
  /// INITIALIZE - Crear meta inicial si no existen
  /// =======================
  Future<void> initializeUserSavingGoal(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Crear un SavingGoal de ejemplo
      final goal = SavingGoal(
        title: 'Meta inicial',
        saved: 0,
        goal: 1000,
        icon: Icons.star,
        color: Colors.blue,
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );

      await addSavingGoal(goal, userId);
      print('🎯 SavingGoal inicial creado para el usuario $userId');
    } else {
      print('🎯 Ya existe al menos un SavingGoal para $userId');
    }
  }

  /// =======================
  /// UPDATE - Actualizar meta
  /// =======================
  Future<void> updateSavingGoal(String goalId, SavingGoal goal) async {
    try {
      await _firestore.collection(_collection).doc(goalId).update({
        'title': goal.title,
        'saved': goal.saved,
        'goal': goal.goal,
        'icon': goal.icon.codePoint,
        'iconFontFamily': goal.icon.fontFamily,
        'color': goal.color.value,
        'targetDate': Timestamp.fromDate(goal.targetDate),
        'payments': goal.payments.map((p) => p.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al actualizar SavingGoal ❌: $e');
      rethrow;
    }
  }

  /// =======================
  /// ADD MONEY - Abonar
  /// =======================
  Future<void> addMoneyToGoal(String goalId, double amount) async {
    try {
      final ref = _firestore.collection(_collection).doc(goalId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);

        final currentSaved = (snapshot['saved'] as num).toDouble();
        final currentPayments = (snapshot['payments'] as List<dynamic>?)
                ?.map((p) => Payment.fromMap(p as Map<String, dynamic>))
                .toList() ??
            [];

        currentPayments.add(Payment(amount: amount, date: DateTime.now()));

        transaction.update(ref, {
          'saved': currentSaved + amount,
          'payments': currentPayments.map((p) => p.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error al abonar SavingGoal ❌: $e');
      rethrow;
    }
  }

  /// =======================
  /// DELETE - Eliminar meta
  /// =======================
  Future<void> deleteSavingGoal(String goalId) async {
    try {
      await _firestore.collection(_collection).doc(goalId).delete();
    } catch (e) {
      print('Error al eliminar SavingGoal ❌: $e');
      rethrow;
    }
  }
}
