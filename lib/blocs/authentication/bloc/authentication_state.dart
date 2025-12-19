part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  authenticated,
  unauthenticated,
  modified, //!No deberia ir aqui pero de mientras
  unknown,
  error, // Nuevo estado para manejar errores
}

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final User user;
  final String? errorMessage; // Mensaje de error opcional

  const AuthenticationState({
    this.status = AuthenticationStatus.unknown,
    this.user = User.empty,
    this.errorMessage,
  });

  const AuthenticationState.unknown() : this();

  const AuthenticationState.authenticated(User user)
    : this(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
    : this(status: AuthenticationStatus.unauthenticated);

  const AuthenticationState.modified(User user)
    : this(status: AuthenticationStatus.modified, user: user);

  // Nuevo constructor para estado de error
  const AuthenticationState.error(String message)
    : this(status: AuthenticationStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, user, errorMessage];
}
