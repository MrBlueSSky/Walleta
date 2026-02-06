import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:walleta/models/payment.dart';

class PaymentRepository {
  PaymentRepository();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen a Firebase Storage
  Future<String> uploadReceiptImage(String userId, String filePath) async {
    try {
      final fileName =
          'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg'; //!Ver si uso uuid.v4()
      final ref = _storage.ref().child('receipts/$userId/$fileName');

      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error subiendo imagen: $e');
      rethrow;
    }
  }

  // Agregar pago con imagen
  Future<void> addPaymentWithImage({required Payment payment}) async {
    try {
      String? receiptUrl = "https//no-image.com/default.jpg";

      final Uuid uuid = Uuid(); // Instancia única
      final String paymentId = uuid.v4();

      // Subir imagen si existe
      // if (payment.receiptImageUrl != null) {
      //   receiptUrl = await uploadReceiptImage(
      //     payment.userId,
      //     payment.receiptImageUrl!,
      //   );
      // }

      // Crear pago con URL de imagen
      final paymentWithImage = Payment(
        id: paymentId,
        loanId: payment.loanId,
        userId: payment.userId,
        amount: payment.amount,
        date: payment.date,
        receiptImageUrl: receiptUrl,
        note: payment.note,
      );

      await _firestore.collection('payments').add(paymentWithImage.toMap());
    } catch (e) {
      print('Error agregando pago con imagen: $e');
      rethrow;
    }
  }

  // Obtener pagos por préstamo
  Future<List<Payment>> fetchPaymentsByLoan(String loanId) async {
    try {
      final snapshot =
          await _firestore
              .collection('payments')
              .where('loanId', isEqualTo: loanId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Error obteniendo pagos: $e');
      rethrow;
    }
  }

  // Obtener TODOS los pagos del usuario (no solo por préstamo)
  Future<List<Payment>> fetchPaymentsByUser(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('payments')
              .where('userId', isEqualTo: userId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo pagos del usuario: $e');
      rethrow;
    }
  }

  // En repository/payment/payment.dart
  Future<List<Payment>> fetchPaymentsByLoanIds(List<String> loanIds) async {
    try {
      if (loanIds.isEmpty) {
        return [];
      }

      // Limitar a 30 IDs (límite de Firestore para whereIn)
      final limitedLoanIds =
          loanIds.length > 30 ? loanIds.sublist(0, 30) : loanIds;

      final snapshot =
          await _firestore
              .collection('payments')
              .where('loanId', whereIn: limitedLoanIds)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error obteniendo pagos por loanIds: $e');
      rethrow;
    }
  }

  // Obtener pagos donde el usuario está involucrado (como prestamista o prestatario)
  Future<List<Payment>> fetchPaymentsInvolvingUser(
    String userId,
    List<String> loanIds,
  ) async {
    try {
      if (loanIds.isEmpty) return [];

      final snapshot =
          await _firestore
              .collection('payments')
              .where('loanId', whereIn: loanIds)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return Payment.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Error obteniendo pagos del usuario: $e');
      rethrow;
    }
  }

  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      print('Error eliminando pago: $e');
      rethrow;
    }
  }
}
