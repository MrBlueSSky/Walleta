import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/income_payment.dart';

class IncomePaymentRepository {
  IncomePaymentRepository();

  // Obtener todos los pagos de un ingreso específico
  Future<List<IncomePayment>> fetchIncomePayments(String incomeId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('income_payments')
            .where('incomeId', isEqualTo: incomeId)
            .orderBy('date', descending: true)
            .get();

    print('💰 Fetched ${snapshot.docs.length} payments for income $incomeId ✅');

    return snapshot.docs.map((doc) {
      return IncomePayment.fromMap(doc.id, doc.data());
    }).toList();
  }

  // Agregar un pago
  Future<void> addIncomePayment({required IncomePayment payment}) async {
    try {
      await FirebaseFirestore.instance
          .collection('income_payments')
          .add(payment.toMap());
      print('✅ Pago agregado exitosamente');
    } catch (e) {
      print('Error al agregar pago ❌: $e');
      rethrow;
    }
  }

  // Actualizar el monto pagado del ingreso
  Future<void> updateIncomePaidAmount({
    required String incomeId,
    required double newPaidAmount,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('income')
          .doc(incomeId)
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
  Future<void> deleteIncomePayment(String paymentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('income_payments')
          .doc(paymentId)
          .delete();
      print('✅ Pago eliminado exitosamente');
    } catch (e) {
      print('Error al eliminar pago ❌: $e');
      rethrow;
    }
  }
}
