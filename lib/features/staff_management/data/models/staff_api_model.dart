import '../../domain/entities/staff_entity.dart';

class StaffApiModel {
  final String? id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String status;

  StaffApiModel({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
  });

  factory StaffApiModel.fromJson(Map<String, dynamic> json) {
    return StaffApiModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      'status': status,
    };
  }

  StaffEntity toEntity() {
    return StaffEntity(
      id: id ?? '',
      name: name,
      email: email,
      phone: phone,
      role: _mapRole(role),
      status: _mapStatus(status),
    );
  }

  static StaffRole _mapRole(String role) {
    return role == 'CASHIER' ? StaffRole.CASHIER : StaffRole.WAITER;
  }

  static StaffStatus _mapStatus(String status) {
    return status == 'INACTIVE' ? StaffStatus.INACTIVE : StaffStatus.ACTIVE;
  }

  factory StaffApiModel.fromEntity(StaffEntity entity) {
    return StaffApiModel(
      id: entity.id.isEmpty ? null : entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role.name,
      status: entity.status.name,
    );
  }
}
