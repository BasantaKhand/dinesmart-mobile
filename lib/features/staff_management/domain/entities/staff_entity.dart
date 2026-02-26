import 'package:equatable/equatable.dart';

enum StaffRole { WAITER, CASHIER }

enum StaffStatus { ACTIVE, INACTIVE }

class StaffEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final StaffRole role;
  final StaffStatus status;

  const StaffEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, status];

  StaffEntity copyWith({
    String? name,
    String? email,
    String? phone,
    StaffRole? role,
    StaffStatus? status,
  }) {
    return StaffEntity(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
