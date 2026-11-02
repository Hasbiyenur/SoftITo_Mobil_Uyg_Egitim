import 'package:flutter/foundation.dart';

@immutable
class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email; // Normalize edilmiş (küçük harf, trimlenmiş)
  final String passwordSalt;
  final String passwordHash;
  final String createdAtUtc;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordSalt,
    required this.passwordHash,
    required this.createdAtUtc,
  });

  String get fullName => '$firstName $lastName'.trim();

  AppUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? passwordSalt,
    String? passwordHash,
    String? createdAtUtc,
  }) {
    return AppUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'passwordSalt': passwordSalt,
    'passwordHash': passwordHash,
    'createdAtUtc': createdAtUtc,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: (json['email'] as String).trim().toLowerCase(),
      passwordSalt: json['passwordSalt'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAtUtc: json['createdAtUtc'] as String,
    );
  }
}
