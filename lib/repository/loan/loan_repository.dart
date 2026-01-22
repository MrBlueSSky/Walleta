import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/loan.dart';

class LoanRepository {
  LoanRepository();

  /// Trae todos los préstamos donde el usuario participa
  Future<List<Loan>> fetchLoans(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('loans')
            .where(
              Filter.or(
                Filter('lenderUserId', isEqualTo: userId),
                Filter('borrowerUserId', isEqualTo: userId),
              ),
            )
            .orderBy('createdAt', descending: true) // ✅ Ordenar por createdAt
            .get();

    print('💸 Fetched ${snapshot.docs.length} loans from Firestore ✅');

    return snapshot.docs.map((doc) {
      return Loan.fromMap(doc.id, doc.data());
    }).toList();
  }

  /// Agregar un préstamo (visible para ambos usuarios)
  Future<void> addLoan(Loan loan) async {
    try {
      await FirebaseFirestore.instance.collection('loans').add({
        'id': loan.id,
        'lenderUserId': loan.lenderUserId.uid,
        'lenderName': loan.lenderUserId.name,
        'lenderSurname': loan.lenderUserId.surname,
        'lenderEmail': loan.lenderUserId.email,
        'lenderUsername': loan.lenderUserId.username,

        'borrowerUserId': loan.borrowerUserId.uid,
        'borrowerName': loan.borrowerUserId.name,
        'borrowerSurname': loan.borrowerUserId.surname,
        'borrowerEmail': loan.borrowerUserId.email,
        'borrowerUsername': loan.borrowerUserId.username,

        'description': loan.description,
        'amount': loan.amount,
        'paidAmount': loan.paidAmount,
        'dueDate': Timestamp.fromDate(loan.dueDate),
        'status': loan.status.name,
        'color': loan.color.value,
        'createdAt': FieldValue.serverTimestamp(), // ✅ Agregar timestamp
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al guardar Loan ❌: $e');
    }
  }

  /// Eliminar préstamo
  Future<void> deleteLoan(String loanId) async {
    try {
      await FirebaseFirestore.instance.collection('loans').doc(loanId).delete();
    } catch (e) {
      print('Error al eliminar Loan ❌: $e');
    }
  }

  /// Actualizar préstamo (abonos, estado, fecha, etc)
  Future<void> updateLoan(Loan loan) async {
    try {
      await FirebaseFirestore.instance.collection('loans').doc(loan.id).update({
        'description': loan.description,
        'amount': loan.amount,
        'paidAmount': loan.paidAmount,
        'dueDate': Timestamp.fromDate(loan.dueDate),
        'status': loan.status.name,
        'color': loan.color.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al actualizar Loan ❌: $e');
    }
  }
}
