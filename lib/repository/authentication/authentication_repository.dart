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
  final StreamController<AppUser> _userController =
      StreamController<AppUser>.broadcast();

  //!Lo dio gepeto para quitar el cuando se quita de fireAuth
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  AuthenticationRepository({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance {
    // Inicializar el stream
    _initializeUserStream();
  }

  // Stream público que cualquier componente puede escuchar
  Stream<AppUser> get user => _userController.stream;

  void _initializeUserStream() {
    // Escuchar cambios en la autenticación de Firebase
    _firebaseAuth
        .authStateChanges()
        .asyncMap((firebaseUser) async {
          print(
            '🔄 authStateChanges detectado - Usuario: ${firebaseUser?.uid}',
          );

          if (firebaseUser == null) {
            return AppUser.empty;
          }

          try {
            // Recargar usuario para obtener datos frescos
            await firebaseUser.reload();

            // Obtener datos actualizados de Firestore
            final userData = await getUserDataFromFirestore(firebaseUser.uid);
            final appUser = userData.toAppUser(firebaseUser.uid);

            print(
              '✅ Usuario cargado desde Firestore - isPremium: ${appUser.isPremium}',
            );

            // Emitir al StreamController
            _userController.add(appUser);

            return appUser;
          } catch (e) {
            print('❌ Error en authStateChanges: $e');
            return AppUser.empty;
          }
        })
        .listen(
          (user) {
            // Esto asegura que siempre emitamos algo
            if (user != AppUser.empty) {
              _userController.add(user);
            }
          },
          onError: (error) {
            print('❌ Error en stream de authStateChanges: $error');
          },
        );
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
      print('🔐 Intentando login con email: $email');

      firebase_auth.UserCredential result = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final authUser = result.user;

      if (authUser == null) {
        throw Exception("Usuario no autenticado");
      }

      // Forzar recarga inmediata
      await authUser.reload();

      Map<String, dynamic> userData = await getUserDataFromFirestore(
        authUser.uid,
      );

      final appUser = userData.toAppUser(authUser.uid);

      // Emitir usuario al stream
      _userController.add(appUser);

      print('✅ Login exitoso - isPremium: ${appUser.isPremium}');

      return appUser;
    } on Exception catch (e) {
      print("❌ No sirvio el login con email y password: $e");
      throw LoginWithEmailAndPasswordFailure();
    }
  }

  Future<Map<String, dynamic>> getUserDataFromFirestore(String uid) async {
    try {
      print('📡 Obteniendo datos de Firestore para: $uid');

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        print('📊 Datos obtenidos - isPremium: ${data['isPremium']}');
        return data;
      } else {
        print('⚠️ No se encontraron datos para el usuario: $uid');
        throw Exception("No se encontraron datos para el usuario.");
      }
    } catch (e) {
      print('❌ Error en getUserDataFromFirestore: $e');
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      print('🚪 Cerrando sesión...');
      await _firebaseAuth.signOut();

      // Emitir usuario vacío
      _userController.add(AppUser.empty);

      print('✅ Sesión cerrada exitosamente');
    } on Exception catch (e) {
      print("❌ No sirvio el logout: $e");
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
      print('👤 Registrando nuevo usuario: $email');

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

      // Obtener datos recién creados
      final userData = await getUserDataFromFirestore(authUser.uid);
      final appUser = userData.toAppUser(authUser.uid);

      // Emitir al stream
      _userController.add(appUser);

      print(
        '✅ Usuario registrado exitosamente - isPremium: ${appUser.isPremium}',
      );

      return appUser;
    } on Exception catch (e) {
      print("❌ No sirvio el registro del user completo: $e");
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
            'isPremium': false,
            'premiumUntil': null,
            'createdAt': now,
            'updatedAt': now,
          });

      print("✅ Usuario registrado correctamente en Firestore");
    } catch (e) {
      print("❌ Error registrando usuario en Firestore: $e");
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
      print('✏️ Actualizando usuario: $uid');

      await updateUserData(
        uid: uid,
        name: name,
        surname: surname,
        phone: phone,
        email: email,
        profilePictureUrl: profilePictureUrl,
      );

      // Obtener datos actualizados
      final userData = await getUserDataFromFirestore(uid);
      final appUser = userData.toAppUser(uid);

      // Emitir al stream
      _userController.add(appUser);

      print('✅ Usuario actualizado - isPremium: ${appUser.isPremium}');

      return appUser;
    } catch (e) {
      print("❌ No se pudo actualizar el usuario completo: $e");
      rethrow;
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
        'phoneNumber': phone,
        'email': email.toLowerCase(),
        'profilePictureUrl': profilePictureUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Datos de usuario actualizados en Firestore');
    } catch (e) {
      print("❌ Error actualizando usuario en Firestore: $e");
      rethrow;
    }
  }

  // 🔥 MÉTODO CORREGIDO PARA UPGRADE A PREMIUM
  Future<void> upgradeToPremium({
    required String userId,
    required Duration duration,
  }) async {
    try {
      print('⭐ Iniciando upgrade a premium para usuario: $userId');
      print('📅 Duración: ${duration.inDays} días');

      final premiumUntil = DateTime.now().add(duration);

      // 1. Actualizar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumUntil': Timestamp.fromDate(premiumUntil),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Firestore actualizado correctamente');

      // 2. Forzar recarga del usuario de Firebase Auth
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        print('✅ Firebase Auth recargado');
      }

      // 3. Obtener datos actualizados de Firestore
      final userData = await getUserDataFromFirestore(userId);
      final updatedUser = userData.toAppUser(userId);

      print('🎉 Usuario actualizado - isPremium: ${updatedUser.isPremium}');

      // 4. Emitir usuario actualizado al stream
      _userController.add(updatedUser);

      // 5. Pequeña pausa para asegurar propagación
      await Future.delayed(Duration(milliseconds: 500));

      print('🚀 Upgrade a premium completado exitosamente');
    } catch (e) {
      print("❌ Error actualizando a premium: $e");
      rethrow;
    }
  }

  // Método para recargar usuario manualmente
  Future<void> reloadCurrentUser() async {
    try {
      print('🔄 Recargando usuario manualmente...');

      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.reload();
        final userData = await getUserDataFromFirestore(firebaseUser.uid);
        final updatedUser = userData.toAppUser(firebaseUser.uid);

        _userController.add(updatedUser);

        print('✅ Usuario recargado - isPremium: ${updatedUser.isPremium}');
      } else {
        print('⚠️ No hay usuario autenticado para recargar');
      }
    } catch (e) {
      print('❌ Error al recargar usuario: $e');
    }
  }

  // Método para obtener usuario actual de forma síncrona
  Future<AppUser?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userData = await getUserDataFromFirestore(firebaseUser.uid);
      return userData.toAppUser(firebaseUser.uid);
    } catch (e) {
      print('❌ Error obteniendo usuario actual: $e');
      return null;
    }
  }

  // Método para verificar estado premium con validación de fecha
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
          final isStillPremium = premiumUntil.isAfter(DateTime.now());

          print(
            '🔍 Verificación premium: $isPremium, hasta: $premiumUntil, aún válido: $isStillPremium',
          );

          return isStillPremium;
        }
      }
      return false;
    } catch (e) {
      print("❌ Error verificando premium: $e");
      return false;
    }
  }

  // Método para limpiar recursos
  void dispose() {
    _userController.close();
  }
}

extension UserFromMap on Map<String, dynamic> {
  AppUser toAppUser(String uid) {
    try {
      print(
        '🔄 Convirtiendo mapa a AppUser - isPremium en mapa: ${this['isPremium']}',
      );

      return AppUser(
        uid: uid,
        username: this['username']?.toString() ?? '',
        name: this['name']?.toString() ?? '',
        email: this['email']?.toString() ?? '',
        surname: this['surname']?.toString() ?? '',
        phoneNumber: this['phoneNumber']?.toString() ?? '',
        profilePictureUrl: this['profilePictureUrl']?.toString() ?? '',
        isPremium:
            this['isPremium'] is bool
                ? (this['isPremium'] as bool)
                : this['isPremium']?.toString().toLowerCase() == 'true',
        premiumUntil:
            this['premiumUntil'] != null
                ? (this['premiumUntil'] as Timestamp).toDate()
                : null,
      );
    } catch (e) {
      print('❌ Error en toAppUser: $e');
      print('📋 Datos del mapa: $this');
      rethrow;
    }
  }
}
