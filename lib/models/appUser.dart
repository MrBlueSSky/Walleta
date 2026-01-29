import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phoneNumber;
  final String profilePictureUrl;
  final bool isPremium;
  final DateTime? premiumUntil;
  final List<String> sharedExpenseIds;

  const AppUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    this.isPremium = false,
    this.premiumUntil,
    this.sharedExpenseIds = const [],
  });

  static const empty = AppUser(
    uid: '',
    username: '',
    name: '',
    surname: '',
    email: '',
    phoneNumber: '',
    profilePictureUrl: '',
    isPremium: false,
    sharedExpenseIds: [],
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
      isPremium: data['isPremium'] ?? false,
      premiumUntil:
          data['premiumUntil'] != null
              ? (data['premiumUntil'] as Timestamp).toDate()
              : null,
      sharedExpenseIds: List<String>.from(data['sharedExpenseIds'] ?? []), // 👈
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'surname': surname,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'isPremium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'sharedExpenseIds': sharedExpenseIds, // 👈
    };
  }

  // Getter para verificar si el premium está activo
  bool get isPremiumActive {
    if (!isPremium) return false;
    if (premiumUntil == null) return false;
    return premiumUntil!.isAfter(DateTime.now());
  }

  // Métodos de conveniencia para sharedExpenseIds
  AppUser copyWith({
    String? uid,
    String? username,
    String? name,
    String? surname,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    bool? isPremium,
    DateTime? premiumUntil,
    List<String>? sharedExpenseIds,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      sharedExpenseIds: sharedExpenseIds ?? this.sharedExpenseIds,
    );
  }

  /// Agregar un expenseId
  AppUser withAddedExpenseId(String expenseId) {
    return copyWith(sharedExpenseIds: [...sharedExpenseIds, expenseId]);
  }

  /// Remover un expenseId
  AppUser withRemovedExpenseId(String expenseId) {
    return copyWith(
      sharedExpenseIds:
          sharedExpenseIds.where((id) => id != expenseId).toList(),
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
    isPremium,
    premiumUntil,
    sharedExpenseIds,
  ];
}
