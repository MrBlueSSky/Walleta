import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleta/models/appUser.dart';

//!Luego meto todos estos posibles fallos en un archivo de errores
class SignUpFailure implements Exception {}

class LoginWithEmailAndPasswordFailure implements Exception {}

class LogInWithGoogleFailure implements Exception {}

class LogOutFailure implements Exception {}

class PasswordResetFailure implements Exception {
  final String message;
  PasswordResetFailure(this.message);
}

class AuthenticationRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  //!Lo dio gepeto para quitar el cuando se quita de fireAuth
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  AuthenticationRepository({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Stream<AppUser> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return AppUser.empty;
      }

      Map<String, dynamic> userData = await getUserDataFromFirestore(
        firebaseUser.uid,
      );

      return userData.toAppUser(firebaseUser.uid);
    });
  }

  // 🔥 Login con Google pero usando solo Firebase
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    final googleProvider = firebase_auth.GoogleAuthProvider();

    // si quieres pedir scopes extra:
    // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');

    // en Web funciona con Popup, en móvil Firebase usa las APIs internas
    return await _firebaseAuth.signInWithPopup(googleProvider);
  }

  //!Iniciar sesion con email y password
  Future<AppUser> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      firebase_auth.UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final authUser = result.user;

      if (authUser == null) {
        throw Exception("Usuario no autenticado");
      }

      Map<String, dynamic> userData = await getUserDataFromFirestore(
        authUser.uid,
      );
      return userData.toAppUser(authUser.uid);
    } on Exception {
      print("No sirvio el login con email y password: ❌❌❌❌❌");
      throw LoginWithEmailAndPasswordFailure();
    }
  }

  Future<Map<String, dynamic>> getUserDataFromFirestore(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      throw Exception("No se encontraron datos para el usuario.");
    }
  }

  Future<void> logOut() async {
    try {
      // await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      await _firebaseAuth.signOut();
    } on Exception {
      print("No sirvio el logout: ❌❌❌❌❌");
      throw LogOutFailure();
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe una cuenta con este correo electrónico.';
          break;
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'too-many-requests':
          errorMessage = 'Demasiados intentos. Intenta de nuevo más tarde.';
          break;
        default:
          errorMessage = 'Error al enviar el correo de recuperación.';
      }

      throw PasswordResetFailure(errorMessage);
    } catch (e) {
      print("❌ Error inesperado: $e");
      throw PasswordResetFailure('Error inesperado al procesar la solicitud.');
    }
  }

  //!Login con google
  // Future<void> logInWithGoogle() async {
  //   try {
  //     final googleUser = await _googleSignIn.signIn();
  //     final googleAuth = await googleUser?.authentication;
  //     final credential = firebase_auth.GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //     await _firebaseAuth.signInWithCredential(credential);
  //   } on Exception {
  //     print("No sirvio el login con google: ❌❌❌❌❌");
  //     throw LogInWithGoogleFailure();
  //   }
  // }

  Future<AppUser> signUp({
    required String username,
    required String name,
    required String surname,
    required String phone,
    required String email,
    required String password,
    required String profilePictureUrl,
  }) async {
    try {
      firebase_auth.UserCredential result = await registerAuthUser(
        email,
        password,
      );

      final authUser = result.user;

      if (authUser == null) {
        throw Exception("Usuario no autenticado");
      }

      await registerUser(
        authUser,
        username,
        name,
        surname,
        email,
        phone,
        profilePictureUrl,
      );

      return AppUser(
        uid: authUser.uid,
        username: username,
        name: name,
        surname: surname,
        email: email,
        phoneNumber: phone,
        profilePictureUrl: profilePictureUrl,
      );
    } on Exception {
      print("No sirvio el registro del user completo ❌❌❌❌❌");
      throw SignUpFailure();
    }
  }

  Future<firebase_auth.UserCredential> registerAuthUser(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> registerUser(
    firebase_auth.User firebaseUser,
    String username,
    String name,
    String surname,
    String email,
    String phone,
    String? profilePictureUrl,
  ) async {
    try {
      final now = FieldValue.serverTimestamp();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
            'uid': firebaseUser.uid,
            'username': username.toLowerCase(),
            'email': email.toLowerCase(),
            'name': name,
            'surname': surname,
            'phoneNumber': phone,
            'profilePictureUrl': profilePictureUrl ?? '',
            'role': 'user',
            'isActive': true,
            'isPremium': false, // ← Agregar este campo
            'createdAt': now,
            'updatedAt': now,
          });

      print("✅ Usuario registrado correctamente");
    } catch (e) {
      print("❌ Error registrando usuario");
      print(e);
      rethrow;
    }
  }

  Future<AppUser> updateUser({
    required String uid,
    required String username,
    required String name,
    required String surname,
    required String phone,
    required String email,
    required String profilePictureUrl,
  }) async {
    try {
      await updateUserData(
        uid: uid,
        name: name,
        surname: surname,
        phone: phone,
        email: email,
        profilePictureUrl: profilePictureUrl,
      );

      return AppUser(
        uid: uid,
        username: username,
        name: name,
        surname: surname,
        email: email,
        phoneNumber: phone,
        profilePictureUrl: profilePictureUrl,
      );
    } catch (e) {
      print("No sirvio se pudo actualizar el user completo: ❌❌❌❌❌");
      print(e);
      rethrow; //!sigue su camino y deja que el error lo maneje otro
    }
  }

  Future<void> updateUserData({
    required String uid,
    required String name,
    required String surname,
    required String phone,
    required String email,
    required String profilePictureUrl,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': name,
        'surname': surname,
        'phone': phone,
        'email': email,
        'profilePictureUrl': profilePictureUrl,
      });
    } catch (e) {
      print("No sirvio se pudo actualizar el user: ❌❌❌❌❌");
      print(e);
    }
  }

  // Agrega este método a tu AuthenticationRepository
  Future<void> upgradeToPremium({
    required String userId,
    required Duration duration,
  }) async {
    try {
      final premiumUntil = DateTime.now().add(duration);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumUntil': Timestamp.fromDate(premiumUntil),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("✅ Usuario actualizado a premium");
    } catch (e) {
      print("❌ Error actualizando a premium: $e");
      rethrow;
    }
  }

  // Método para verificar estado premium
  Future<bool> checkPremiumStatus(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        final isPremium = data['isPremium'] ?? false;

        if (isPremium && data['premiumUntil'] != null) {
          final premiumUntil = (data['premiumUntil'] as Timestamp).toDate();
          return premiumUntil.isAfter(DateTime.now());
        }
      }
      return false;
    } catch (e) {
      print("❌ Error verificando premium: $e");
      return false;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userData = await getUserDataFromFirestore(firebaseUser.uid);
    return userData.toAppUser(firebaseUser.uid);
  }
}

extension on firebase_auth.User {
  AppUser get toAppUser {
    return AppUser(
      uid: uid,
      username: '',
      name: displayName ?? '',
      surname: '',
      email: email ?? '',
      phoneNumber: phoneNumber ?? '',
      profilePictureUrl: photoURL ?? '',
    );
  }
}

extension UserFromMap on Map<String, dynamic> {
  AppUser toAppUser(String uid) {
    return AppUser(
      uid: uid,
      username: this['username'] ?? '',
      name: this['name'] ?? '',
      email: this['email'] ?? '',
      surname: this['surname'] ?? '',
      phoneNumber: this['phoneNumber'] ?? '',
      profilePictureUrl: this['profilePictureUrl'] ?? '',
    );
  }
}
