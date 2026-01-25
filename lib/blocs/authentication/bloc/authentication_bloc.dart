import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walleta/models/appUser.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:walleta/repository/repository.dart';

part 'authentication_state.dart';
part 'authentication_event.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<AppUser> _userSubscription;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository,
       super(const AuthenticationState.unknown()) {
    _userSubscription = _authenticationRepository.user.listen(
      (user) => add(AuthenticationUserChanged(user)),
    );

    on<AuthenticationPasswordResetRequested>((event, emit) async {
      try {
        await _authenticationRepository.resetPassword(email: event.email);
      } catch (e) {
        print('Error en password reset: $e');
      }
    });

    on<AuthenticationUserChanged>((event, emit) async {
      // await Future.delayed(
      //   const Duration(seconds: 5),
      // ); //! Simula un retaro pa ver el spalsh
      emit(_mapAuthenticationUserChangedToState(event));

      //!Esto me lo dio gepeto para eliminar el user de fireAuth//////////////
      try {
        final currentUser = _authenticationRepository.currentUser;

        await currentUser?.reload(); // Fuerza la recarga desde Firebase

        final refreshedUser = _authenticationRepository.currentUser;

        if (refreshedUser == null) {
          // El usuario fue eliminado de FirebaseAuth
          emit(const AuthenticationState.unauthenticated());
        } else {
          await Future.delayed(const Duration(seconds: 5)); // Simula splash
          emit(_mapAuthenticationUserChangedToState(event));
        }
      } catch (_) {
        emit(const AuthenticationState.unauthenticated());
      }
      //!Hasta aqui/////////////////////////////////////////////////////
    });

    on<AuthenticationUserSignIn>((event, emit) async {
      try {
        final user = await _authenticationRepository.logInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        emit(AuthenticationState.authenticated(user));
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        emit(AuthenticationState.error(errorMessage));

        // Después de mostrar el error, volver a unauthenticated para permitir nuevos intentos
        await Future.delayed(const Duration(milliseconds: 100));
        if (!isClosed) {
          emit(const AuthenticationState.unauthenticated());
        }
      }
    });

    //! Aqui se maneja el evento de logout
    on<AuthenticationLogoutRequested>((event, emit) async {
      await _authenticationRepository.logOut();
      emit(const AuthenticationState.unauthenticated());
    });

    //!Manejar la autentication del usuario que se registre
    on<AuthenticationUserRegister>((event, emit) async {
      try {
        final user = await _authenticationRepository.signUp(
          username: event.username,
          name: event.name,
          surname: event.surname,
          phone: event.phone,
          email: event.email,
          password: event.password,
          profilePictureUrl: event.profilePictureUrl,
        );

        emit(AuthenticationState.authenticated(user));
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        emit(AuthenticationState.error(errorMessage));
      }
    });

    on<UpdateUser>((event, emit) async {
      try {
        final user = await _authenticationRepository.updateUser(
          uid: event.uid,
          username: event.username,
          name: event.name,
          surname: event.surname,
          phone: event.phone,
          email: event.email,
          profilePictureUrl: event.profilePictureUrl,
        );

        emit(
          AuthenticationState.authenticated(user),
        ); //!Puede ser este o el estado modified es la misma vaina pero luego muvo logica
        // emit(AuthenticationState.modified(user));
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        emit(AuthenticationState.error(errorMessage));
      }
    });

    // En authentication_bloc.dart
    on<UpgradeToPremium>((event, emit) async {
      try {
        await _authenticationRepository.upgradeToPremium(
          userId: event.userId,
          duration: event.duration,
        );

        // Recargar usuario actualizado
        final updatedUser = await _authenticationRepository.getCurrentUser();

        if (updatedUser != null) {
          emit(AuthenticationState.authenticated(updatedUser));
        }
      } catch (e) {
        emit(AuthenticationState.error('Error al actualizar a premium'));
      }
    });
  } //?Fin del constructor

  String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No se encontró un usuario con ese correo electrónico.';
        case 'wrong-password':
          return 'La contraseña es incorrecta.';
        case 'invalid-email':
          return 'La dirección de correo electrónico no es válida.';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde.';
        case 'invalid-credential':
          return 'Las credenciales proporcionadas son incorrectas.';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con este correo electrónico.';
        case 'weak-password':
          return 'La contraseña es muy débil.';
        case 'network-request-failed':
          return 'Error de conexión. Verifica tu internet.';
        default:
          return 'Ocurrió un error inesperado. Intenta nuevamente.';
      }
    }
    return 'Ocurrió un error inesperado. Intenta nuevamente.';
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
    AuthenticationUserChanged event,
  ) {
    return event.user != AppUser.empty
        ? AuthenticationState.authenticated(event.user)
        : const AuthenticationState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
