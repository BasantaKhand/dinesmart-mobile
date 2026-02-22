import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String restaurantName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String address;
  final String message;
  final String? username;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.restaurantName,
    required this.ownerName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.message,
    this.username,
    this.password,
    this.profilePicture,
  });

  String get fullName => ownerName;

  @override
  List<Object?> get props => [
    authId,
    restaurantName,
    ownerName,
    email,
    phoneNumber,
    address,
    message,
    username,
    password,
    profilePicture,
  ];
}
