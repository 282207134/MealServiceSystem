import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/order_model.dart';

class OrderRepository {
  final SupabaseClient? _supabaseClient;
  final Uuid _uuid;

  OrderRepository({SupabaseClient? supabase, Uuid? uuid})
      : _supabaseClient = supabase,
        _uuid = uuid ?? const Uuid();

  SupabaseClient get _client {
    final client = _supabaseClient;
    if (client == null) {
      throw StateError('Supabase 未初始化');
    }
    return client;
  }

  /// 创建订单
  Future<OrderModel> createOrder({
    required String userId,
    required String merchantId,
    required double totalAmount,
    required List<OrderItemModel> items,
    String? note,
  }) async {
    try {
      final orderNumber = _generateOrderNumber();
      final now = DateTime.now();

      final orderData = {
        'order_number': orderNumber,
        'user_id': userId,
        'merchant_id': merchantId,
        'total_amount': totalAmount,
        'status': OrderStatus.pending.value,
        'note': note,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final orderResponse = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;

      final itemsData = items
          .map((item) => {
                'order_id': orderId,
                'product_id': item.productId,
                'product_name': item.productName,
                'quantity': item.quantity,
                'unit_price': item.unitPrice,
                'subtotal': item.subtotal,
              })
          .toList();

      await _client.from('order_items').insert(itemsData);

      return OrderModel.fromJson(orderResponse);
    } catch (e) {
      throw Exception('创建订单失败: $e');
    }
  }

  /// 获取用户订单列表
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取用户订单失败: $e');
    }
  }

  /// 获取商家订单列表
  Future<List<OrderModel>> getMerchantOrders(String merchantId,
      {OrderStatus? status}) async {
    try {
      var query = _client
          .from('orders')
          .select('*, order_items(*), users(*)')
          .eq('merchant_id', merchantId);

      if (status != null) {
        query = query.eq('status', status.value);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取商家订单失败: $e');
    }
  }

  /// 获取订单详情
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('获取订单详情失败: $e');
    }
  }

  /// 更新订单状态
  Future<OrderModel> updateOrderStatus(
      String orderId, OrderStatus status) async {
    try {
      final response = await _client
          .from('orders')
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('更新订单状态失败: $e');
    }
  }

  /// 取消订单
  Future<OrderModel> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// 生成订单号
  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(3);
    final random = _uuid.v4().substring(0, 4).toUpperCase();
    return 'ORD$timestamp$random';
  }
}
