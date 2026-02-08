import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/personal_expense.dart';

class PersonalExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección
  CollectionReference get _collection =>
      _firestore.collection('personal_expenses');

  /// Obtener todos los gastos de un usuario
  Future<List<PersonalExpense>> fetchExpenses(String userId) async {
    try {
      final querySnapshot =
          await _collection
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return PersonalExpense.fromMap(doc.id, {
          ...doc.data() as Map<String, dynamic>,
          'userId': userId,
        });
      }).toList();
    } catch (e) {
      print('Error fetching expenses: $e');
      throw Exception('Failed to load expenses');
    }
  }

  /// Agregar un nuevo gasto
  Future<void> addExpense(PersonalExpense expense, String userId) async {
    try {
      final data = expense.toMap();
      data['userId'] = userId;
      data['createdAt'] = Timestamp.now();

      final DocumentReference docRef = await _collection.add(data);

      //!rEGISTRO EL PAGO INICIAL SI ES QUE SE HIZO UN PAGO AL CREAR EL GASTO
      await FirebaseFirestore.instance
          .collection('personal_expenses_payments')
          .add({
            'expenseId': docRef.id,
            'amount': expense.paid,
            'userId': userId,
            'createdAt': Timestamp.now(),
          });
    } catch (e) {
      print('Error adding expense: $e');
      throw Exception('Failed to add expense');
    }
  }

  /// Actualizar un gasto existente
  Future<void> updateExpense(PersonalExpense expense) async {
    try {
      if (expense.id == null) throw Exception('Expense ID is required');

      await _collection.doc(expense.id!).update(expense.toMap());
    } catch (e) {
      print('Error updating expense: $e');
      throw Exception('Failed to update expense');
    }
  }

  /// Eliminar un gasto
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _collection.doc(expenseId).delete();
    } catch (e) {
      print('Error deleting expense: $e');
      throw Exception('Failed to delete expense');
    }
  }

  /// Registrar un pago en el gasto
  Future<void> addPayment(String expenseId, double amount) async {
    try {
      final doc = await _collection.doc(expenseId).get();
      if (!doc.exists) throw Exception('Expense not found');

      final data = doc.data() as Map<String, dynamic>;
      final currentPaid = (data['paid'] as num).toDouble();
      final newPaid = currentPaid + amount;

      await _collection.doc(expenseId).update({
        'paid': newPaid,
        'status': _calculateStatus(newPaid, data['total']),
        'lastPaymentAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding payment: $e');
      throw Exception('Failed to add payment');
    }
  }

  /// Método helper para calcular estado
  String _calculateStatus(double paid, dynamic total) {
    final totalAmount = (total as num).toDouble();
    if (paid <= 0) return 'pending';
    if (paid >= totalAmount) return 'paid';
    return 'partially_paid';
  }
}
