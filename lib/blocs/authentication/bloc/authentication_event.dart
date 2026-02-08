part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationUserChanged extends AuthenticationEvent {
  final AppUser user;

  const AuthenticationUserChanged(this.user);

  @override
  List<Object> get props => [user];
}

class AuthenticationUserSignIn extends AuthenticationEvent {
  final String email;
  final String password;

  const AuthenticationUserSignIn({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthenticationLogoutRequested extends AuthenticationEvent {}

class AuthenticationUserRegister extends AuthenticationEvent {
  final String username;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String password;
  final String profilePictureUrl;

  const AuthenticationUserRegister({
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.password,
    required this.profilePictureUrl,
  });

  @override
  List<Object> get props => [
    username,
    name,
    surname,
    phone,
    email,
    password,
    profilePictureUrl,
  ];
}

class UpdateUser extends AuthenticationEvent {
  final String uid;
  final String username;
  final String name;
  final String surname;
  final String phone;
  final String email;
  final String profilePictureUrl;

  const UpdateUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.surname,
    required this.phone,
    required this.email,
    required this.profilePictureUrl,
  });

  @override
  List<Object> get props => [
    uid,
    username,
    name,
    surname,
    phone,
    email,
    profilePictureUrl,
  ];
}

class UpgradeToPremium extends AuthenticationEvent {
  final String userId;
  final Duration duration;

  const UpgradeToPremium({required this.userId, required this.duration});

  @override
  List<Object> get props => [userId, duration];
}

class ReloadUserRequested extends AuthenticationEvent {}

class AuthenticationPasswordResetRequested extends AuthenticationEvent {
  final String email;

  const AuthenticationPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}
