import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/shared_expense.dart';

class SharedExpenseRepository {
  SharedExpenseRepository();

  Future<List<SharedExpense>> fetchSharedExpenses(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('sharedExpenses')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();

    print(
      '🐢🐢🐢Fetched ${snapshot.docs.length} shared expenses from Firestore ✅',
    );

    return snapshot.docs.map((doc) {
      return SharedExpense.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<void> addSharedExpense({
    required SharedExpense expense,
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('sharedExpenses').add({
        'userId': userId,
        ...expense.toMap(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar SharedExpense ❌: $e');
    }
  }

  Future<void> deleteSharedExpense(SharedExpense expenseId) async {}

  Future<void> updateSharedExpense(SharedExpense expense) async {}
}
