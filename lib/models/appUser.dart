import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;

  const AppUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
  });

  static const empty = AppUser(
    uid: '',
    username: '',
    name: '',
    surname: '',
    email: '',
    phoneNumber: '',
    profilePictureUrl: '',
  );

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
    );
  }

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
}
