# API 使用示例

本文档提供了完整的 Supabase API 调用示例代码，可以直接在项目中使用。

## 📋 目录

- [认证 (Authentication)](#认证-authentication)
- [商家管理 (Merchant Management)](#商家管理-merchant-management)
- [分类管理 (Category Management)](#分类管理-category-management)
- [商品管理 (Product Management)](#商品管理-product-management)
- [订单管理 (Order Management)](#订单管理-order-management)
- [图片上传 (Image Upload)](#图片上传-image-upload)
- [实时订阅 (Real-time Subscriptions)](#实时订阅-real-time-subscriptions)

## 认证 (Authentication)

### 用户注册

```dart
// lib/data/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 用户注册
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'customer', // 'customer' 或 'merchant'
  }) async {
    try {
      // 1. 在 Auth 中注册用户
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('注册失败');
      }

      // 2. 在 users 表中创建用户记录
      await _supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role,
      });

      return authResponse;
    } catch (e) {
      throw Exception('注册失败: $e');
    }
  }

  /// 用户登录
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('登录失败: $e');
    }
  }

  /// 用户登出
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('登出失败: $e');
    }
  }

  /// 获取当前用户
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// 获取当前用户信息（包含 users 表中的数据）
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = getCurrentUser();
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  /// 更新用户信息
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      await _supabase
          .from('users')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      throw Exception('更新用户信息失败: $e');
    }
  }

  /// 重置密码
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('重置密码失败: $e');
    }
  }
}
```

### 使用示例

```dart
// 在登录页面中使用
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authRepository = AuthRepository();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _authRepository.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (response.user != null) {
        // 登录成功，导航到主页
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI 实现...
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: '邮箱'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: '密码'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading 
              ? CircularProgressIndicator() 
              : Text('登录'),
          ),
        ],
      ),
    );
  }
}
```

## 商家管理 (Merchant Management)

```dart
// lib/data/repositories/merchant_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 创建商家
  Future<Map<String, dynamic>> createMerchant({
    required String userId,
    required String name,
    String? description,
    String? avatarUrl,
    String? coverImageUrl,
  }) async {
    try {
      final response = await _supabase
          .from('merchants')
          .insert({
            'user_id': userId,
            'name': name,
            'description': description,
            'avatar_url': avatarUrl,
            'cover_image_url': coverImageUrl,
            'is_active': true,
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('创建商家失败: $e');
    }
  }

  /// 获取商家信息
  Future<Map<String, dynamic>?> getMerchant(String merchantId) async {
    try {
      final response = await _supabase
          .from('merchants')
          .select()
          .eq('id', merchantId)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('获取商家信息失败: $e');
    }
  }

  /// 获取用户的商家信息
  Future<Map<String, dynamic>?> getMerchantByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('merchants')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      return response;
    } catch (e) {
      throw Exception('获取商家信息失败: $e');
    }
  }

  /// 获取所有活跃商家列表
  Future<List<Map<String, dynamic>>> getActiveMerchants() async {
    try {
      final response = await _supabase
          .from('merchants')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取商家列表失败: $e');
    }
  }

  /// 更新商家信息
  Future<void> updateMerchant({
    required String merchantId,
    String? name,
    String? description,
    String? avatarUrl,
    String? coverImageUrl,
    bool? isActive,
    Map<String, dynamic>? openingHours,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (coverImageUrl != null) data['cover_image_url'] = coverImageUrl;
      if (isActive != null) data['is_active'] = isActive;
      if (openingHours != null) data['opening_hours'] = openingHours;

      await _supabase
          .from('merchants')
          .update(data)
          .eq('id', merchantId);
    } catch (e) {
      throw Exception('更新商家信息失败: $e');
    }
  }

  /// 切换营业状态
  Future<void> toggleMerchantStatus(String merchantId, bool isActive) async {
    try {
      await _supabase
          .from('merchants')
          .update({'is_active': isActive})
          .eq('id', merchantId);
    } catch (e) {
      throw Exception('切换营业状态失败: $e');
    }
  }
}
```

## 分类管理 (Category Management)

```dart
// lib/data/repositories/category_repository.dart

class CategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取商家的所有分类
  Future<List<Map<String, dynamic>>> getCategories(String merchantId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('merchant_id', merchantId)
          .order('display_order', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取分类列表失败: $e');
    }
  }

  /// 创建分类
  Future<Map<String, dynamic>> createCategory({
    required String merchantId,
    required String name,
    String? description,
    int displayOrder = 0,
  }) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert({
            'merchant_id': merchantId,
            'name': name,
            'description': description,
            'display_order': displayOrder,
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('创建分类失败: $e');
    }
  }

  /// 更新分类
  Future<void> updateCategory({
    required String categoryId,
    String? name,
    String? description,
    int? displayOrder,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (displayOrder != null) data['display_order'] = displayOrder;

      await _supabase
          .from('categories')
          .update(data)
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('更新分类失败: $e');
    }
  }

  /// 删除分类
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw Exception('删除分类失败: $e');
    }
  }
}
```

## 商品管理 (Product Management)

```dart
// lib/data/repositories/product_repository.dart

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 获取商品列表
  Future<List<Map<String, dynamic>>> getProducts({
    String? merchantId,
    String? categoryId,
    bool? isAvailable,
  }) async {
    try {
      var query = _supabase
          .from('products')
          .select('*, categories(id, name)')
          .order('display_order', ascending: true);

      if (merchantId != null) {
        query = query.eq('merchant_id', merchantId);
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取商品列表失败: $e');
    }
  }

  /// 获取单个商品详情
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, categories(id, name)')
          .eq('id', productId)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('获取商品详情失败: $e');
    }
  }

  /// 创建商品
  Future<Map<String, dynamic>> createProduct({
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
      final response = await _supabase
          .from('products')
          .insert({
            'merchant_id': merchantId,
            'category_id': categoryId,
            'name': name,
            'description': description,
            'price': price,
            'image_url': imageUrl,
            'is_available': isAvailable,
            'stock_quantity': stockQuantity,
            'display_order': displayOrder,
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('创建商品失败: $e');
    }
  }

  /// 更新商品
  Future<void> updateProduct({
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
      final data = <String, dynamic>{};
      if (categoryId != null) data['category_id'] = categoryId;
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (price != null) data['price'] = price;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isAvailable != null) data['is_available'] = isAvailable;
      if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
      if (displayOrder != null) data['display_order'] = displayOrder;

      await _supabase
          .from('products')
          .update(data)
          .eq('id', productId);
    } catch (e) {
      throw Exception('更新商品失败: $e');
    }
  }

  /// 删除商品
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
  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
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
  Future<List<Map<String, dynamic>>> searchProducts({
    required String merchantId,
    required String keyword,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, categories(id, name)')
          .eq('merchant_id', merchantId)
          .eq('is_available', true)
          .or('name.ilike.%$keyword%,description.ilike.%$keyword%')
          .order('display_order', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('搜索商品失败: $e');
    }
  }
}
```

## 订单管理 (Order Management)

```dart
// lib/data/repositories/order_repository.dart

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 创建订单
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String merchantId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? note,
  }) async {
    try {
      // 1. 创建订单
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'merchant_id': merchantId,
            'total_amount': totalAmount,
            'status': 'pending',
            'note': note,
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // 2. 创建订单项
      final orderItems = items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['product_id'],
          'product_name': item['product_name'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'subtotal': item['quantity'] * item['unit_price'],
        };
      }).toList();

      await _supabase
          .from('order_items')
          .insert(orderItems);

      // 3. 返回完整订单信息
      return await getOrder(orderId);
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }

  /// 获取订单详情
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            users(id, full_name, phone),
            merchants(id, name),
            order_items(
              *,
              products(id, name, image_url)
            )
          ''')
          .eq('id', orderId)
          .single();
      
      return response;
    } catch (e) {
      throw Exception('获取订单详情失败: $e');
    }
  }

  /// 获取用户的订单列表（顾客端）
  Future<List<Map<String, dynamic>>> getUserOrders({
    required String userId,
    String? status,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('orders')
          .select('''
            *,
            merchants(id, name, avatar_url),
            order_items(
              *,
              products(id, name, image_url)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取订单列表失败: $e');
    }
  }

  /// 获取商家的订单列表（商家端）
  Future<List<Map<String, dynamic>>> getMerchantOrders({
    required String merchantId,
    String? status,
    int limit = 100,
  }) async {
    try {
      var query = _supabase
          .from('orders')
          .select('''
            *,
            users(id, full_name, phone),
            order_items(
              *,
              products(id, name, image_url)
            )
          ''')
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false)
          .limit(limit);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取订单列表失败: $e');
    }
  }

  /// 更新订单状态
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('更新订单状态失败: $e');
    }
  }

  /// 取消订单
  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('取消订单失败: $e');
    }
  }

  /// 获取订单统计（商家端）
  Future<Map<String, dynamic>> getOrderStatistics({
    required String merchantId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('orders')
          .select('status, total_amount')
          .eq('merchant_id', merchantId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final orders = List<Map<String, dynamic>>.from(response);

      // 统计数据
      int totalOrders = orders.length;
      int pendingOrders = orders.where((o) => o['status'] == 'pending').length;
      int completedOrders = orders.where((o) => o['status'] == 'completed').length;
      double totalRevenue = orders
          .where((o) => o['status'] == 'completed')
          .fold(0.0, (sum, o) => sum + (o['total_amount'] as num).toDouble());

      return {
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'completed_orders': completedOrders,
        'total_revenue': totalRevenue,
      };
    } catch (e) {
      throw Exception('获取订单统计失败: $e');
    }
  }
}
```

## 图片上传 (Image Upload)

```dart
// lib/data/repositories/storage_repository.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String bucketName = 'product-images';

  /// 从相册选择图片
  Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// 从相机拍照
  Future<File?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// 上传商品图片
  Future<String> uploadProductImage({
    required String merchantId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = 'merchants/$merchantId/products/$fileName';

      await _supabase.storage
          .from(bucketName)
          .upload(filePath, imageFile);

      final imageUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('上传图片失败: $e');
    }
  }

  /// 上传商家头像
  Future<String> uploadMerchantAvatar({
    required String merchantId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final filePath = 'merchants/$merchantId/$fileName';

      await _supabase.storage
          .from(bucketName)
          .upload(filePath, imageFile);

      final imageUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('上传头像失败: $e');
    }
  }

  /// 删除图片
  Future<void> deleteImage(String imageUrl) async {
    try {
      // 从 URL 中提取文件路径
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucketName);
      
      if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        
        await _supabase.storage
            .from(bucketName)
            .remove([filePath]);
      }
    } catch (e) {
      throw Exception('删除图片失败: $e');
    }
  }
}
```

## 实时订阅 (Real-time Subscriptions)

```dart
// lib/data/repositories/realtime_repository.dart

import 'dart:async';

class RealtimeRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 订阅商家的新订单（商家端）
  StreamSubscription subscribeToNewOrders({
    required String merchantId,
    required Function(Map<String, dynamic>) onNewOrder,
  }) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .listen((List<Map<String, dynamic>> data) {
          for (var order in data) {
            if (order['status'] == 'pending') {
              onNewOrder(order);
            }
          }
        });
  }

  /// 订阅订单状态更新（顾客端）
  StreamSubscription subscribeToOrderStatus({
    required String orderId,
    required Function(Map<String, dynamic>) onStatusUpdate,
  }) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            onStatusUpdate(data.first);
          }
        });
  }

  /// 订阅用户的所有订单（顾客端）
  StreamSubscription subscribeToUserOrders({
    required String userId,
    required Function(List<Map<String, dynamic>>) onOrdersUpdate,
  }) {
    return _supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((List<Map<String, dynamic>> data) {
          onOrdersUpdate(data);
        });
  }

  /// 订阅商品可用性变化
  StreamSubscription subscribeToProductAvailability({
    required String merchantId,
    required Function(List<Map<String, dynamic>>) onProductsUpdate,
  }) {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .listen((List<Map<String, dynamic>> data) {
          onProductsUpdate(data);
        });
  }
}
```

### 使用实时订阅示例

```dart
// 在商家端订单管理页面
class MerchantOrdersScreen extends StatefulWidget {
  final String merchantId;

  const MerchantOrdersScreen({required this.merchantId});

  @override
  _MerchantOrdersScreenState createState() => _MerchantOrdersScreenState();
}

class _MerchantOrdersScreenState extends State<MerchantOrdersScreen> {
  final _realtimeRepository = RealtimeRepository();
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToNewOrders();
  }

  void _subscribeToNewOrders() {
    _subscription = _realtimeRepository.subscribeToNewOrders(
      merchantId: widget.merchantId,
      onNewOrder: (order) {
        // 显示新订单通知
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('新订单：${order['order_number']}'),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {
                // 导航到订单详情
              },
            ),
          ),
        );
        
        // 刷新订单列表
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI 实现...
    return Scaffold(
      appBar: AppBar(title: Text('订单管理')),
      body: Container(),
    );
  }
}
```

## 完整示例：创建订单流程

```dart
// 完整的下单流程示例
class CheckoutService {
  final OrderRepository _orderRepository = OrderRepository();
  final ProductRepository _productRepository = ProductRepository();

  Future<Map<String, dynamic>> placeOrder({
    required String userId,
    required String merchantId,
    required List<CartItem> cartItems,
    String? note,
  }) async {
    try {
      // 1. 验证商品可用性和价格
      for (var item in cartItems) {
        final product = await _productRepository.getProduct(item.productId);
        
        if (product == null || !product['is_available']) {
          throw Exception('商品 ${item.productName} 已下架');
        }
        
        if (product['price'] != item.unitPrice) {
          throw Exception('商品 ${item.productName} 价格已变更');
        }
        
        // 检查库存（如果有）
        if (product['stock_quantity'] != null) {
          if (product['stock_quantity'] < item.quantity) {
            throw Exception('商品 ${item.productName} 库存不足');
          }
        }
      }

      // 2. 计算总金额
      double totalAmount = 0;
      for (var item in cartItems) {
        totalAmount += item.quantity * item.unitPrice;
      }

      // 3. 创建订单
      final orderItems = cartItems.map((item) => {
        'product_id': item.productId,
        'product_name': item.productName,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      }).toList();

      final order = await _orderRepository.createOrder(
        userId: userId,
        merchantId: merchantId,
        items: orderItems,
        totalAmount: totalAmount,
        note: note,
      );

      return order;
    } catch (e) {
      throw Exception('下单失败: $e');
    }
  }
}

// CartItem 模型
class CartItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}
```

## 错误处理最佳实践

```dart
// 统一的错误处理
class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  ApiException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

// 在 Repository 中使用
Future<List<Map<String, dynamic>>> getProducts() async {
  try {
    final response = await _supabase
        .from('products')
        .select()
        .eq('is_available', true);
    
    return List<Map<String, dynamic>>.from(response);
  } on PostgrestException catch (e) {
    throw ApiException(
      '数据库查询失败',
      code: e.code,
      details: e.message,
    );
  } on AuthException catch (e) {
    throw ApiException(
      '认证失败',
      code: e.statusCode,
      details: e.message,
    );
  } catch (e) {
    throw ApiException('未知错误: $e');
  }
}
```

## 分页加载示例

```dart
// 实现分页加载
class PaginatedProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const int pageSize = 20;

  Future<List<Map<String, dynamic>>> getProductsPage({
    required String merchantId,
    required int page,
  }) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _supabase
          .from('products')
          .select()
          .eq('merchant_id', merchantId)
          .eq('is_available', true)
          .order('display_order')
          .range(from, to);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('获取商品列表失败: $e');
    }
  }
}
```

---

以上示例覆盖了校园点餐系统的主要功能。可以根据实际需求进行调整和扩展。
