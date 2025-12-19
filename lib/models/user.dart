import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String uid;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;

  const User({
    required this.uid,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
  }) : assert(username != null);

  static const empty = User(
    uid: '',
    username: '',
    name: '',
    surname: '',
    email: '',
    phoneNumber: '',
    profilePictureUrl: '',
  );

  @override
  List<Object?> get props => [
    uid,
    username,
    name,
    surname,
    email,
    phoneNumber,
    profilePictureUrl,
  ];

  @override
  bool get stringify => true;
}
