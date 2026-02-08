part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  authenticated,
  unauthenticated,
  loading, // Nuevo estado para carga
  unknown,
  error,
}

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final AppUser user;
  final String? errorMessage;

  const AuthenticationState({
    this.status = AuthenticationStatus.unknown,
    this.user = AppUser.empty,
    this.errorMessage,
  });

  const AuthenticationState.unknown() : this();

  const AuthenticationState.authenticated(AppUser user)
    : this(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
    : this(status: AuthenticationStatus.unauthenticated);

  const AuthenticationState.loading(AppUser user)
    : this(status: AuthenticationStatus.loading, user: user);

  const AuthenticationState.error(String message)
    : this(status: AuthenticationStatus.error, errorMessage: message);

  // Método para copiar con cambios
  AuthenticationState copyWith({
    AuthenticationStatus? status,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
