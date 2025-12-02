import 'package:equatable/equatable.dart';

/// 商品数据模型
class ProductModel extends Equatable {
  /// 商品唯一标识符
  final String id;

  /// 所属商家ID
  final String merchantId;

  /// 所属分类ID（可选）
  final String? categoryId;

  /// 商品名称
  final String name;

  /// 商品描述
  final String? description;

  /// 商品价格（单位：元）
  final double price;

  /// 商品图片URL
  final String? imageUrl;

  /// 是否可用（上架/下架）
  final bool isAvailable;

  /// 库存数量（null 表示不限制库存）
  final int? stockQuantity;

  /// 显示顺序（用于排序）
  final int displayOrder;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.merchantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.stockQuantity,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建商品模型
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'stock_quantity': stockQuantity,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 创建商品副本
  ProductModel copyWith({
    String? id,
    String? merchantId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    int? stockQuantity,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        merchantId,
        categoryId,
        name,
        description,
        price,
        imageUrl,
        isAvailable,
        stockQuantity,
        displayOrder,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, isAvailable: $isAvailable)';
  }
}
