import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
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

  const AuthApiModel({
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

  Map<String, dynamic> toJson() {
    return {
      'restaurantName': restaurantName,
      'ownerName': ownerName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'message': message,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      authId: (json['_id'] ?? json['id'])?.toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      ownerName: (json['ownerName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      username: json['username']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      restaurantName: restaurantName,
      ownerName: ownerName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      message: message,
      username: username,
      password: password,
      profilePicture: profilePicture,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      authId: entity.authId,
      restaurantName: entity.restaurantName,
      ownerName: entity.ownerName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      address: entity.address,
      message: entity.message,
      username: entity.username,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }
}
