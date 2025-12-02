import 'package:equatable/equatable.dart';

/// 订单状态枚举
enum OrderStatus {
  pending('pending', '待确认'),
  confirmed('confirmed', '已确认'),
  preparing('preparing', '制作中'),
  ready('ready', '待取餐'),
  completed('completed', '已完成'),
  cancelled('cancelled', '已取消');

  final String value;
  final String displayName;

  const OrderStatus(this.value, this.displayName);

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// 订单数据模型
class OrderModel extends Equatable {
  final String id;
  final String orderNumber;
  final String userId;
  final String merchantId;
  final double totalAmount;
  final OrderStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemModel>? items;
  final Map<String, dynamic>? userInfo;
  final Map<String, dynamic>? merchantInfo;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.merchantId,
    required this.totalAmount,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.items,
    this.userInfo,
    this.merchantInfo,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel>? items;
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String,
      merchantId: json['merchant_id'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: OrderStatus.fromValue(json['status'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: items,
      userInfo: json['users'] as Map<String, dynamic>?,
      merchantInfo: json['merchants'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'merchant_id': merchantId,
      'total_amount': totalAmount,
      'status': status.value,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    String? merchantId,
    double? totalAmount,
    OrderStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      merchantId: merchantId ?? this.merchantId,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        userId,
        merchantId,
        totalAmount,
        status,
        note,
        createdAt,
        updatedAt,
      ];
}

/// 订单项模型
class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final Map<String, dynamic>? productInfo;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.productInfo,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      productInfo: json['products'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
    Map<String, dynamic>? productInfo,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      productInfo: productInfo ?? this.productInfo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        quantity,
        unitPrice,
        subtotal,
      ];
}
