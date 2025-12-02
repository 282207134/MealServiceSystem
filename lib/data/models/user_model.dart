import 'package:equatable/equatable.dart';

enum UserRole {
  customer('customer', '顾客'),
  merchant('merchant', '商家'),
  admin('admin', '管理员');

  final String value;
  final String displayName;

  const UserRole(this.value, this.displayName);

  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.customer,
    );
  }
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromValue(json['role'] as String),
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        fullName,
        phone,
        avatarUrl,
        createdAt,
        updatedAt,
      ];
}
