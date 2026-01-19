// repository/payment/payment_repository.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:walleta/models/payment.dart';

class PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir imagen a Firebase Storage
  Future<String> uploadReceiptImage(String userId, String filePath) async {
    try {
      final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      String? receiptUrl;

      // Subir imagen si existe
      if (payment.receiptImageUrl != null) {
        receiptUrl = await uploadReceiptImage(
          payment.userId,
          payment.receiptImageUrl!,
        );
      }

      // Crear pago con URL de imagen
      final paymentWithImage = Payment(
        id: payment.id,
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

  // Obtener pagos por usuario
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
