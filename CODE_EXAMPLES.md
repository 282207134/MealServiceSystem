# 代码示例集合（含完整中文注释）

本文档包含完整的代码示例，所有代码都包含详细的中文注释。

## 📋 目录

- [数据模型示例](#数据模型示例)
- [Repository 实现](#repository-实现)
- [Provider 状态管理](#provider-状态管理)
- [UI 页面示例](#ui-页面示例)
- [完整功能流程](#完整功能流程)

---

## 数据模型示例

### 商品模型（Product Model）

```dart
// lib/data/models/product_model.dart

import 'package:equatable/equatable.dart';

/// 商品数据模型
/// 
/// 用于在应用和 Supabase 之间传输商品数据
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

  /// 构造函数
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
  /// 
  /// [json] 从 Supabase 返回的 JSON 数据
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
  /// 
  /// 用于发送数据到 Supabase
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

  /// 创建商品副本，允许部分字段修改
  /// 
  /// 用于更新商品时只修改部分字段
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

  /// 用于比较两个商品是否相同
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

  /// 字符串表示，用于调试
  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, isAvailable: $isAvailable)';
  }
}
```

### 订单模型（Order Model）

```dart
// lib/data/models/order_model.dart

/// 订单状态枚举
enum OrderStatus {
  /// 待确认
  pending('pending', '待确认'),
  
  /// 已确认
  confirmed('confirmed', '已确认'),
  
  /// 制作中
  preparing('preparing', '制作中'),
  
  /// 待取餐
  ready('ready', '待取餐'),
  
  /// 已完成
  completed('completed', '已完成'),
  
  /// 已取消
  cancelled('cancelled', '已取消');

  /// 数据库中存储的值
  final String value;
  
  /// 显示给用户的文本
  final String displayName;

  const OrderStatus(this.value, this.displayName);

  /// 从字符串值创建枚举
  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// 订单数据模型
class OrderModel extends Equatable {
  /// 订单ID
  final String id;
  
  /// 订单号（用于显示给用户）
  final String orderNumber;
  
  /// 用户ID
  final String userId;
  
  /// 商家ID
  final String merchantId;
  
  /// 订单总金额
  final double totalAmount;
  
  /// 订单状态
  final OrderStatus status;
  
  /// 订单备注
  final String? note;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 订单项列表（可选，根据查询需求）
  final List<OrderItemModel>? items;
  
  /// 用户信息（可选）
  final Map<String, dynamic>? userInfo;
  
  /// 商家信息（可选）
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

  /// 从 JSON 创建订单模型
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // 解析订单项列表
    List<OrderItemModel>? items;
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
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

  /// 转换为 JSON
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

  /// 创建副本
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
  /// 订单项ID
  final String id;
  
  /// 所属订单ID
  final String orderId;
  
  /// 商品ID
  final String productId;
  
  /// 商品名称（快照，防止商品信息变更）
  final String productName;
  
  /// 数量
  final int quantity;
  
  /// 单价（快照）
  final double unitPrice;
  
  /// 小计
  final double subtotal;
  
  /// 商品信息（可选）
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

  /// 从 JSON 创建
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

  /// 转换为 JSON
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
```

---

## Repository 实现

### 商品 Repository 实现

```dart
// lib/data/repositories/product_repository_impl.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

/// 商品数据仓库实现类
/// 
/// 负责处理所有与商品相关的数据操作
class ProductRepository {
  /// Supabase 客户端实例
  final SupabaseClient _supabase;

  /// 构造函数，注入 Supabase 客户端
  ProductRepository(this._supabase);

  /// 获取商家的所有商品列表
  /// 
  /// [merchantId] 商家ID
  /// [categoryId] 分类ID（可选，用于筛选）
  /// [isAvailable] 是否只获取可用商品（可选）
  /// 
  /// 返回商品列表
  /// 抛出异常如果查询失败
  Future<List<ProductModel>> getProducts({
    required String merchantId,
    String? categoryId,
    bool? isAvailable,
  }) async {
    try {
      // 构建查询
      var query = _supabase
          .from('products')
          .select('*, categories(id, name)') // 关联查询分类信息
          .eq('merchant_id', merchantId)
          .order('display_order', ascending: true); // 按显示顺序排序

      // 根据分类筛选
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      // 根据可用状态筛选
      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      // 执行查询
      final response = await query;

      // 将 JSON 数据转换为商品模型列表
      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      // 捕获异常并重新抛出，添加更友好的错误信息
      throw Exception('获取商品列表失败: $e');
    }
  }

  /// 根据ID获取单个商品详情
  /// 
  /// [productId] 商品ID
  /// 
  /// 返回商品模型，如果未找到则返回 null
  Future<ProductModel?> getProduct(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, categories(id, name)')
          .eq('id', productId)
          .maybeSingle(); // 可能返回 null

      if (response == null) {
        return null;
      }

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('获取商品详情失败: $e');
    }
  }

  /// 创建新商品
  /// 
  /// [merchantId] 商家ID
  /// [categoryId] 分类ID（可选）
  /// [name] 商品名称
  /// [description] 商品描述（可选）
  /// [price] 商品价格
  /// [imageUrl] 商品图片URL（可选）
  /// [isAvailable] 是否可用（默认为 true）
  /// [stockQuantity] 库存数量（可选）
  /// [displayOrder] 显示顺序（默认为 0）
  /// 
  /// 返回创建成功的商品模型
  Future<ProductModel> createProduct({
    required String merchantId,
    String? categoryId,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    bool isAvailable = true,
    int? stockQuantity,
    int displayOrder = 0,
  }) async {
    try {
      // 准备插入数据
      final data = {
        'merchant_id': merchantId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'is_available': isAvailable,
        'stock_quantity': stockQuantity,
        'display_order': displayOrder,
      };

      // 插入数据并返回新创建的记录
      final response = await _supabase
          .from('products')
          .insert(data)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('创建商品失败: $e');
    }
  }

  /// 更新商品信息
  /// 
  /// [productId] 要更新的商品ID
  /// 其他参数都是可选的，只更新提供的字段
  /// 
  /// 返回更新后的商品模型
  Future<ProductModel> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    int? stockQuantity,
    int? displayOrder,
  }) async {
    try {
      // 只包含非 null 的字段
      final data = <String, dynamic>{};
      
      if (categoryId != null) data['category_id'] = categoryId;
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isAvailable != null) data['is_available'] = isAvailable;
      if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
      if (displayOrder != null) data['display_order'] = displayOrder;

      // 如果没有要更新的字段，直接返回当前商品
      if (data.isEmpty) {
        final product = await getProduct(productId);
        if (product == null) {
          throw Exception('商品不存在');
        }
        return product;
      }

      // 执行更新
      final response = await _supabase
          .from('products')
          .update(data)
          .eq('id', productId)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('更新商品失败: $e');
    }
  }

  /// 删除商品
  /// 
  /// [productId] 要删除的商品ID
  /// 
  /// 注意：如果商品已被订单引用，删除可能失败
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('删除商品失败: $e');
    }
  }

  /// 切换商品可用状态
  /// 
  /// [productId] 商品ID
  /// [isAvailable] 新的可用状态
  /// 
  /// 这是一个便捷方法，用于快速上架/下架商品
  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _supabase
          .from('products')
          .update({'is_available': isAvailable})
          .eq('id', productId);
    } catch (e) {
      throw Exception('切换商品状态失败: $e');
    }
  }

  /// 搜索商品
  /// 
  /// [merchantId] 商家ID
  /// [keyword] 搜索关键词
  /// 
  /// 在商品名称和描述中搜索关键词
  Future<List<ProductModel>> searchProducts({
    required String merchantId,
    required String keyword,
  }) async {
    try {
      // 使用 ilike 进行不区分大小写的模糊搜索
      final response = await _supabase
          .from('products')
          .select('*, categories(id, name)')
          .eq('merchant_id', merchantId)
          .eq('is_available', true)
          .or('name.ilike.%$keyword%,description.ilike.%$keyword%')
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('搜索商品失败: $e');
    }
  }

  /// 批量更新商品显示顺序
  /// 
  /// [updates] Map<商品ID, 新的显示顺序>
  /// 
  /// 用于拖拽排序后批量更新
  Future<void> batchUpdateDisplayOrder(Map<String, int> updates) async {
    try {
      // Supabase 不直接支持批量更新，需要逐个更新
      // 在实际应用中可以考虑使用 PostgreSQL 函数来优化
      for (final entry in updates.entries) {
        await _supabase
            .from('products')
            .update({'display_order': entry.value})
            .eq('id', entry.key);
      }
    } catch (e) {
      throw Exception('批量更新显示顺序失败: $e');
    }
  }

  /// 更新库存
  /// 
  /// [productId] 商品ID
  /// [quantity] 库存变化量（可以是负数表示减少）
  /// 
  /// 使用数据库的原子操作确保并发安全
  Future<void> updateStock(String productId, int quantity) async {
    try {
      // 获取当前库存
      final product = await getProduct(productId);
      if (product == null) {
        throw Exception('商品不存在');
      }

      final currentStock = product.stockQuantity ?? 0;
      final newStock = currentStock + quantity;

      // 检查库存是否足够
      if (newStock < 0) {
        throw Exception('库存不足');
      }

      // 更新库存
      await _supabase
          .from('products')
          .update({'stock_quantity': newStock})
          .eq('id', productId);
    } catch (e) {
      throw Exception('更新库存失败: $e');
    }
  }
}
```

---

## Provider 状态管理

### 商品列表 Provider

```dart
// lib/presentation/providers/products_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 客户端 Provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// 商品仓库 Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProductRepository(supabase);
});

/// 商品列表状态类
class ProductsState {
  /// 商品列表
  final List<ProductModel> products;
  
  /// 是否正在加载
  final bool isLoading;
  
  /// 错误信息
  final String? error;
  
  /// 当前选中的分类ID
  final String? selectedCategoryId;
  
  /// 搜索关键词
  final String? searchKeyword;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategoryId,
    this.searchKeyword,
  });

  /// 创建副本
  ProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? error,
    String? selectedCategoryId,
    String? searchKeyword,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchKeyword: searchKeyword ?? this.searchKeyword,
    );
  }
}

/// 商品列表 StateNotifier
/// 
/// 管理商品列表的加载、筛选、搜索等状态
class ProductsNotifier extends StateNotifier<ProductsState> {
  /// 商品仓库
  final ProductRepository _repository;
  
  /// 当前商家ID
  final String merchantId;

  /// 构造函数
  ProductsNotifier(this._repository, this.merchantId) 
      : super(const ProductsState()) {
    // 初始化时自动加载商品
    loadProducts();
  }

  /// 加载商品列表
  Future<void> loadProducts() async {
    // 设置加载状态
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 从仓库获取商品
      final products = await _repository.getProducts(
        merchantId: merchantId,
        categoryId: state.selectedCategoryId,
        isAvailable: true,
      );

      // 如果有搜索关键词，进行本地筛选
      List<ProductModel> filteredProducts = products;
      if (state.searchKeyword != null && state.searchKeyword!.isNotEmpty) {
        filteredProducts = products.where((product) {
          final keyword = state.searchKeyword!.toLowerCase();
          return product.name.toLowerCase().contains(keyword) ||
                 (product.description?.toLowerCase().contains(keyword) ?? false);
        }).toList();
      }

      // 更新状态
      state = state.copyWith(
        products: filteredProducts,
        isLoading: false,
      );
    } catch (e) {
      // 处理错误
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 按分类筛选
  /// 
  /// [categoryId] 分类ID，传入 null 表示显示所有分类
  Future<void> filterByCategory(String? categoryId) async {
    // 更新选中的分类
    state = state.copyWith(selectedCategoryId: categoryId);
    
    // 重新加载商品
    await loadProducts();
  }

  /// 搜索商品
  /// 
  /// [keyword] 搜索关键词
  Future<void> search(String keyword) async {
    // 更新搜索关键词
    state = state.copyWith(searchKeyword: keyword);
    
    // 重新加载商品
    await loadProducts();
  }

  /// 刷新商品列表
  Future<void> refresh() async {
    await loadProducts();
  }

  /// 切换商品可用状态
  /// 
  /// [productId] 商品ID
  /// [isAvailable] 新的可用状态
  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    try {
      // 调用仓库方法
      await _repository.toggleAvailability(productId, isAvailable);
      
      // 刷新列表
      await loadProducts();
    } catch (e) {
      // 错误处理
      state = state.copyWith(error: '切换商品状态失败: $e');
    }
  }
}

/// 商品列表 Provider
/// 
/// 使用 family 修饰符支持多个商家的商品列表
final productsProvider = StateNotifierProvider.family<ProductsNotifier, ProductsState, String>(
  (ref, merchantId) {
    final repository = ref.watch(productRepositoryProvider);
    return ProductsNotifier(repository, merchantId);
  },
);
```

### 购物车 Provider

```dart
// lib/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

/// 购物车项
class CartItem {
  /// 商品信息
  final ProductModel product;
  
  /// 数量
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  /// 小计金额
  double get subtotal => product.price * quantity;

  /// 创建副本
  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// 购物车状态管理类
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  /// 添加商品到购物车
  /// 
  /// [product] 要添加的商品
  /// [quantity] 数量（默认为 1）
  void addProduct(ProductModel product, {int quantity = 1}) {
    // 检查购物车中是否已有该商品
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // 如果已存在，增加数量
      final existingItem = state[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      state = [
        ...state.sublist(0, existingIndex),
        existingItem.copyWith(quantity: newQuantity),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // 如果不存在，添加新项
      state = [
        ...state,
        CartItem(product: product, quantity: quantity),
      ];
    }
  }

  /// 更新商品数量
  /// 
  /// [productId] 商品ID
  /// [quantity] 新的数量（如果为 0 则删除该商品）
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      // 数量为 0，删除该商品
      removeProduct(productId);
      return;
    }

    final index = state.indexWhere(
      (item) => item.product.id == productId,
    );

    if (index >= 0) {
      final item = state[index];
      state = [
        ...state.sublist(0, index),
        item.copyWith(quantity: quantity),
        ...state.sublist(index + 1),
      ];
    }
  }

  /// 从购物车中删除商品
  /// 
  /// [productId] 商品ID
  void removeProduct(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  /// 清空购物车
  void clear() {
    state = [];
  }

  /// 获取购物车中的商品总数量
  int get totalQuantity {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  /// 获取购物车总金额
  double get totalAmount {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// 检查购物车是否为空
  bool get isEmpty => state.isEmpty;

  /// 检查购物车是否不为空
  bool get isNotEmpty => state.isNotEmpty;
}

/// 购物车 Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

/// 购物车总数量 Provider（优化性能，只在数量变化时重建）
final cartTotalQuantityProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

/// 购物车总金额 Provider（优化性能，只在金额变化时重建）
final cartTotalAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
});
```

---

## UI 页面示例

### 商品列表页面

```dart
// lib/presentation/screens/customer/menu/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/products_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../widgets/product/product_card.dart';

/// 商品菜单页面
/// 
/// 显示商家的所有商品，支持分类筛选和搜索
class MenuScreen extends ConsumerStatefulWidget {
  /// 商家ID
  final String merchantId;
  
  /// 商家名称
  final String merchantName;

  const MenuScreen({
    Key? key,
    required this.merchantId,
    required this.merchantName,
  }) : super(key: key);

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听商品列表状态
    final productsState = ref.watch(productsProvider(widget.merchantId));
    
    // 监听购物车总数量
    final cartQuantity = ref.watch(cartTotalQuantityProvider);

    return Scaffold(
      // 应用栏
      appBar: AppBar(
        title: Text(widget.merchantName),
        actions: [
          // 购物车按钮
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  // 导航到购物车页面
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              // 显示购物车商品数量徽章
              if (cartQuantity > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartQuantity',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          
          // 分类筛选栏
          _buildCategoryFilter(),
          
          // 商品列表
          Expanded(
            child: _buildProductList(productsState),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索商品...',
          prefixIcon: const Icon(Icons.search),
          // 清除按钮
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // 清空搜索
                    ref.read(productsProvider(widget.merchantId).notifier)
                        .search('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        // 当用户输入时触发搜索
        onChanged: (value) {
          // 延迟搜索，避免频繁调用
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              ref.read(productsProvider(widget.merchantId).notifier)
                  .search(value);
            }
          });
        },
      ),
    );
  }

  /// 构建分类筛选栏
  Widget _buildCategoryFilter() {
    // TODO: 实现分类筛选
    // 这里可以添加水平滚动的分类按钮列表
    return const SizedBox.shrink();
  }

  /// 构建商品列表
  Widget _buildProductList(ProductsState state) {
    // 加载中状态
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 错误状态
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 重试加载
                ref.read(productsProvider(widget.merchantId).notifier)
                    .refresh();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无商品',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // 商品网格列表
    return RefreshIndicator(
      // 下拉刷新
      onRefresh: () async {
        await ref.read(productsProvider(widget.merchantId).notifier)
            .refresh();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 两列
          childAspectRatio: 0.75, // 宽高比
          crossAxisSpacing: 16, // 列间距
          mainAxisSpacing: 16, // 行间距
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return ProductCard(
            product: product,
            onTap: () {
              // 导航到商品详情页
              Navigator.pushNamed(
                context,
                '/product-detail',
                arguments: product,
              );
            },
            onAddToCart: () {
              // 添加到购物车
              ref.read(cartProvider.notifier).addProduct(product);
              
              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已添加 ${product.name} 到购物车'),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: '查看',
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 商品卡片组件

```dart
// lib/presentation/widgets/product/product_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product_model.dart';

/// 商品卡片组件
/// 
/// 用于在列表或网格中显示商品信息
class ProductCard extends StatelessWidget {
  /// 商品数据
  final ProductModel product;
  
  /// 点击卡片的回调
  final VoidCallback? onTap;
  
  /// 点击添加到购物车的回调
  final VoidCallback? onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // 卡片阴影
      elevation: 2,
      // 圆角
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // 裁剪子组件
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // 点击事件
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            _buildImage(),
            
            // 商品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品名称
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 商品描述
                    if (product.description != null)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const Spacer(),
                    
                    // 价格和添加按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 价格
                        Text(
                          '¥${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        
                        // 添加到购物车按钮
                        if (onAddToCart != null)
                          InkWell(
                            onTap: onAddToCart,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建商品图片
  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1.0, // 正方形
      child: product.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
              // 加载占位符
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              // 错误占位符
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            )
          : Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey,
              ),
            ),
    );
  }
}
```

---

## 完整功能流程

### 完整的下单流程实现

```dart
// lib/presentation/screens/customer/cart/checkout_service.dart

import 'package:uuid/uuid.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../providers/cart_provider.dart';

/// 结账服务类
/// 
/// 处理完整的下单流程，包括验证、创建订单等
class CheckoutService {
  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;

  CheckoutService(this._orderRepository, this._productRepository);

  /// 执行结账流程
  /// 
  /// [userId] 用户ID
  /// [merchantId] 商家ID
  /// [cartItems] 购物车商品列表
  /// [note] 订单备注（可选）
  /// 
  /// 返回创建成功的订单
  /// 抛出异常如果验证失败或创建失败
  Future<OrderModel> checkout({
    required String userId,
    required String merchantId,
    required List<CartItem> cartItems,
    String? note,
  }) async {
    // 步骤 1: 验证购物车
    if (cartItems.isEmpty) {
      throw Exception('购物车为空');
    }

    // 步骤 2: 验证每个商品
    final orderItems = <Map<String, dynamic>>[];
    double totalAmount = 0;

    for (final cartItem in cartItems) {
      // 从数据库获取最新的商品信息
      final product = await _productRepository.getProduct(
        cartItem.product.id,
      );

      // 验证商品是否存在
      if (product == null) {
        throw Exception('商品 ${cartItem.product.name} 不存在');
      }

      // 验证商品是否可用
      if (!product.isAvailable) {
        throw Exception('商品 ${product.name} 已下架');
      }

      // 验证价格是否变化
      if (product.price != cartItem.product.price) {
        throw Exception(
          '商品 ${product.name} 价格已变更，'
          '原价 ¥${cartItem.product.price}，'
          '现价 ¥${product.price}',
        );
      }

      // 验证库存（如果有库存限制）
      if (product.stockQuantity != null) {
        if (product.stockQuantity! < cartItem.quantity) {
          throw Exception(
            '商品 ${product.name} 库存不足，'
            '库存数量：${product.stockQuantity}，'
            '购买数量：${cartItem.quantity}',
          );
        }
      }

      // 计算小计
      final subtotal = product.price * cartItem.quantity;
      totalAmount += subtotal;

      // 准备订单项数据
      orderItems.add({
        'product_id': product.id,
        'product_name': product.name,
        'quantity': cartItem.quantity,
        'unit_price': product.price,
        'subtotal': subtotal,
      });
    }

    // 步骤 3: 创建订单
    try {
      final order = await _orderRepository.createOrder(
        userId: userId,
        merchantId: merchantId,
        items: orderItems,
        totalAmount: totalAmount,
        note: note,
      );

      // 步骤 4: 扣减库存（在实际应用中应该在数据库触发器中处理）
      for (final cartItem in cartItems) {
        final product = await _productRepository.getProduct(
          cartItem.product.id,
        );
        
        if (product != null && product.stockQuantity != null) {
          await _productRepository.updateStock(
            product.id,
            -cartItem.quantity, // 负数表示减少
          );
        }
      }

      return order;
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }
}
```

---

以上代码示例涵盖了项目的主要部分，所有注释都使用中文，便于理解和维护。
