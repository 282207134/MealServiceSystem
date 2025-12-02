import 'package:equatable/equatable.dart';

/// 商品分类数据模型
class CategoryModel extends Equatable {
  final String id;
  final String merchantId;
  final String name;
  final String? description;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.merchantId,
    required this.name,
    this.description,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? merchantId,
    String? name,
    String? description,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      name: name ?? this.name,
      description: description ?? this.description,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        merchantId,
        name,
        description,
        displayOrder,
        createdAt,
        updatedAt,
      ];
}
