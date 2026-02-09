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
  StreamSubscription<AppUser>? _userSubscription;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository,
       super(const AuthenticationState.unknown()) {
    // 🔥 SUSCRIBIRSE AL STREAM DEL REPOSITORY
    _setupUserSubscription();

    on<AuthenticationPasswordResetRequested>((event, emit) async {
      try {
        await _authenticationRepository.resetPassword(email: event.email);
      } catch (e) {
        print('Error en password reset: $e');
      }
    });

    on<AuthenticationUserChanged>((event, emit) {
      print('🔄 BLoC: AuthenticationUserChanged recibido');
      print('📊 Usuario - isPremium: ${event.user.isPremium}');
      emit(_mapAuthenticationUserChangedToState(event));
    });

    on<AuthenticationUserSignIn>((event, emit) async {
      try {
        emit(AuthenticationState.loading(state.user));

        final user = await _authenticationRepository.logInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        emit(AuthenticationState.authenticated(user));
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        emit(AuthenticationState.error(errorMessage));

        await Future.delayed(const Duration(milliseconds: 100));
        if (!isClosed) {
          emit(const AuthenticationState.unauthenticated());
        }
      }
    });

    on<AuthenticationLogoutRequested>((event, emit) async {
      await _authenticationRepository.logOut();
      emit(const AuthenticationState.unauthenticated());
    });

    on<AuthenticationUserRegister>((event, emit) async {
      try {
        emit(AuthenticationState.loading(state.user));

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
        emit(AuthenticationState.loading(state.user));

        final user = await _authenticationRepository.updateUser(
          uid: event.uid,
          username: event.username,
          name: event.name,
          surname: event.surname,
          phone: event.phone,
          email: event.email,
          profilePictureUrl: event.profilePictureUrl,
        );

        emit(AuthenticationState.authenticated(user));
      } catch (e) {
        String errorMessage = _getErrorMessage(e);
        emit(AuthenticationState.error(errorMessage));
      }
    });

    // 🔥 EVENTO UPGRADE TO PREMIUM CORREGIDO
    on<UpgradeToPremium>((event, emit) async {
      try {
        print('⭐ BLoC: UpgradeToPremium iniciado');

        // 1. Emitir estado de carga
        emit(AuthenticationState.loading(state.user));

        // 2. Actualizar en repository
        await _authenticationRepository.upgradeToPremium(
          userId: event.userId,
          duration: event.duration,
        );

        print('✅ BLoC: Repository actualizado');

        // 3. NO emitir aquí - El stream se encargará automáticamente
        // El AuthenticationUserChanged será disparado por el stream
      } catch (e) {
        print('❌ BLoC: Error en UpgradeToPremium: $e');
        emit(AuthenticationState.error('Error al actualizar a premium: $e'));

        // Volver al estado anterior
        emit(AuthenticationState.authenticated(state.user));
      }
    });

    // 🔥 NUEVO: Evento para forzar recarga manual
    on<ReloadUserRequested>((event, emit) async {
      try {
        print('🔄 BLoC: Recargando usuario manualmente');
        await _authenticationRepository.reloadCurrentUser();
      } catch (e) {
        print('❌ BLoC: Error al recargar usuario: $e');
      }
    });
  }

  // 🔥 MÉTODO PARA SUSCRIBIRSE AL STREAM
  void _setupUserSubscription() {
    _userSubscription?.cancel(); // Cancelar suscripción anterior si existe

    _userSubscription = _authenticationRepository.user.listen(
      (user) {
        print('🎯 BLoC: Stream del repository emitido');
        print('📊 Nuevo usuario recibido - isPremium: ${user.isPremium}');
        print('📊 Estado anterior - isPremium: ${state.user.isPremium}');

        // Solo emitir si el usuario cambió
        if (user.uid != state.user.uid ||
            user.isPremium != state.user.isPremium ||
            user.email != state.user.email) {
          print('🔄 BLoC: Usuario cambió, emitiendo evento...');
          add(AuthenticationUserChanged(user));
        } else {
          print('ℹ️ BLoC: Usuario sin cambios, ignorando');
        }
      },
      onError: (error) {
        print('❌ BLoC: Error en stream: $error');
        add(const AuthenticationUserChanged(AppUser.empty));
      },
    );
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
    AuthenticationUserChanged event,
  ) {
    print('🎯 _mapAuthenticationUserChangedToState llamado');
    print('📊 Event user - isPremium: ${event.user.isPremium}');
    print('📊 Event user - uid: ${event.user.uid}');

    if (event.user != AppUser.empty && event.user.uid.isNotEmpty) {
      print('✅ Emitiendo estado AUTHENTICATED');
      return AuthenticationState.authenticated(event.user);
    } else {
      print('🚫 Emitiendo estado UNAUTHENTICATED');
      return const AuthenticationState.unauthenticated();
    }
  }

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

  // Método para obtener usuario actual
  AppUser get currentUser => state.user;

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
