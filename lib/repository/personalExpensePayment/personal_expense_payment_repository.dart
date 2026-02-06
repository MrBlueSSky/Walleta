import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/personal_expense_payment.dart';

class PersonalExpensePaymentRepository {
  PersonalExpensePaymentRepository();

  // Obtener todos los pagos de un gasto específico
  Future<List<PersonalExpensePayment>> fetchExpensePayments(
    String expenseId,
  ) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('personal_expenses_payments')
            .where('expenseId', isEqualTo: expenseId)
            .orderBy('date', descending: true)
            .get();

    print(
      '💰 Fetched ${snapshot.docs.length} payments for expense $expenseId ✅',
    );

    return snapshot.docs.map((doc) {
      return PersonalExpensePayment.fromMap(doc.id, doc.data());
    }).toList();
  }

  // Agregar un pago
  Future<void> addExpensePayment({
    required PersonalExpensePayment payment,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('personal_expenses_payments')
          .add(payment.toMap());
      print('✅ Pago agregado exitosamente');
    } catch (e) {
      print('Error al agregar pago ❌: $e');
      rethrow;
    }
  }

  // Actualizar el monto pagado del gasto
  Future<void> updateExpensePaidAmount({
    required String expenseId,
    required double newPaidAmount,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('personal_expenses')
          .doc(expenseId)
          .update({
            'paid': newPaidAmount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      print('✅ Monto pagado actualizado: $newPaidAmount');
    } catch (e) {
      print('Error al actualizar monto pagado ❌: $e');
      rethrow;
    }
  }

  // Eliminar un pago
  Future<void> deleteExpensePayment(String paymentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('personal_expenses_payments')
          .doc(paymentId)
          .delete();
      print('✅ Pago eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar pago ❌: $e');
      rethrow;
    }
  }
}
