import 'package:equatable/equatable.dart';

class MerchantModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? coverImageUrl;
  final bool isActive;
  final Map<String, dynamic>? openingHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MerchantModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.avatarUrl,
    this.coverImageUrl,
    this.isActive = true,
    this.openingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      openingHours: json['opening_hours'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'cover_image_url': coverImageUrl,
      'is_active': isActive,
      'opening_hours': openingHours,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MerchantModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? avatarUrl,
    String? coverImageUrl,
    bool? isActive,
    Map<String, dynamic>? openingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MerchantModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isActive: isActive ?? this.isActive,
      openingHours: openingHours ?? this.openingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        avatarUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
