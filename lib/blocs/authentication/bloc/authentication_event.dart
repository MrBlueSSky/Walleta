part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => []; //!Es para saber si dos instacias son iaguales viene de equatable
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final User user; //!Este es el user que viene del stream de firebase.

  const AuthenticationUserChanged(this.user);

  @override
  List<Object> get props => [user]; //!Aqui esta user, tons 2 eventos con distointos user no serán iguales
}

class AuthenticationUserSignIn extends AuthenticationEvent {
  final String email;
  final String password;

  AuthenticationUserSignIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthenticationPasswordResetRequested extends AuthenticationEvent {
  final String email;

  const AuthenticationPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}

//!Registrar al user normal
class AuthenticationUserRegister extends AuthenticationEvent {
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String password;
  final String profilePictureUrl;

  AuthenticationUserRegister({
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.password,
    required this.profilePictureUrl,
  });

  @override
  List<Object> get props => [
    username,
    name,
    surname,
    email,
    phone,
    password,
    profilePictureUrl,
  ];
}

class UpdateUser extends AuthenticationEvent {
  final String uid;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String profilePictureUrl;

  UpdateUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.profilePictureUrl,
  });

  @override
  List<Object> get props => [
    uid,
    name,
    surname,
    email,
    phone,
    profilePictureUrl,
  ];
}
