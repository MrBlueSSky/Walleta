import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/income.dart';

class IncomesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Referencia a la colección
  CollectionReference get _collection => _firestore.collection('incomes');

  Future<List<Incomes>> fetchIncomes(String userId) async {
    try {
      final querySnapshot =
          await _collection
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        return Incomes.fromMap(doc.id, {
          ...doc.data() as Map<String, dynamic>,
          'userId': userId,
        });
      }).toList();
    } catch (e) {
      print('Error fetching incomings: $e');
      throw Exception('Failed to load incomings');
    }
  }

  /// Agregar un nuevo ingreso
  Future<void> addIncoming(Incomes income, String userId) async {
    try {
      final data = income.toMap();
      data['userId'] = userId;
      data['createdAt'] = Timestamp.now();

      await _collection.add(data);
    } catch (e) {
      print('Error adding incoming: $e');
      throw Exception('Failed to add incoming');
    }
  }

  Future<void> updateIncoming(Incomes income) async {
    try {
      if (income.id == null) throw Exception('Incoming ID is required');

      await _collection.doc(income.id!).update(income.toMap());
    } catch (e) {
      print('Error updating income: $e');
      throw Exception('Failed to update income');
    }
  }

  /// Eliminar un ingreso
  Future<void> deleteIncoming(String incomeId) async {
    try {
      await _collection.doc(incomeId).delete();
    } catch (e) {
      print('Error deleting income: $e');
      throw Exception('Failed to delete income');
    }
  }

  /// Registrar un pago en el ingreso
  Future<void> addPayment(String incomeId, double amount) async {
    try {
      final doc = await _collection.doc(incomeId).get();
      if (!doc.exists) throw Exception('Income not found');

      final data = doc.data() as Map<String, dynamic>;
      final currentPaid = (data['paid'] as num).toDouble();
      final newPaid = currentPaid + amount;

      await _collection.doc(incomeId).update({
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
