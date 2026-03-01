import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: HiveBoxConstants.userTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String? restaurantId;

  @HiveField(6)
  final String? phoneNumber;

  @HiveField(7)
  final String? profilePicture;

  @HiveField(8)
  final DateTime? lastUpdated;

  UserHiveModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    required this.role,
    this.restaurantId,
    this.phoneNumber,
    this.profilePicture,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'username': username,
      'role': role,
      'restaurantId': restaurantId,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
    };
  }

  factory UserHiveModel.fromMap(Map<String, dynamic> map) {
    return UserHiveModel(
      id: map['id'] ?? map['_id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      restaurantId: map['restaurantId'],
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      lastUpdated: DateTime.now(),
    );
  }
}
