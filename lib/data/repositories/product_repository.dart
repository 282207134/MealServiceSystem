import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient? _supabase;

  ProductRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient get _client {
    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase 未初始化');
    }
    return client;
  }

  /// 获取商品列表
  Future<List<ProductModel>> getProducts({
    String? merchantId,
    String? categoryId,
    bool? isAvailable,
  }) async {
    try {
      var query = _client.from('products').select('*');

      if (merchantId != null) {
        query = query.eq('merchant_id', merchantId);
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (isAvailable != null) {
        query = query.eq('is_available', isAvailable);
      }

      final response = await query.order('display_order');
      return (response as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取商品列表失败: $e');
    }
  }

  /// 根据ID获取商品
  Future<ProductModel> getProductById(String id) async {
    try {
      final response =
          await _client.from('products').select('*').eq('id', id).single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('获取商品失败: $e');
    }
  }

  /// 创建商品
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('创建商品失败: $e');
    }
  }

  /// 更新商品
  Future<ProductModel> updateProduct(
      String id, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      final response = await _client
          .from('products')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('更新商品失败: $e');
    }
  }

  /// 删除商品
  Future<void> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('删除商品失败: $e');
    }
  }

  /// 搜索商品
  Future<List<ProductModel>> searchProducts(String keyword,
      {String? merchantId}) async {
    try {
      var query = _client
          .from('products')
          .select('*')
          .ilike('name', '%$keyword%')
          .eq('is_available', true);

      if (merchantId != null) {
        query = query.eq('merchant_id', merchantId);
      }

      final response = await query;
      return (response as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('搜索商品失败: $e');
    }
  }

  /// 更新商品库存
  Future<void> updateStock(String id, int newQuantity) async {
    try {
      await _client.from('products').update({
        'stock_quantity': newQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('更新库存失败: $e');
    }
  }

  /// 切换商品可用状态
  Future<void> toggleAvailability(String id, bool isAvailable) async {
    try {
      await _client.from('products').update({
        'is_available': isAvailable,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } catch (e) {
      throw Exception('更新商品状态失败: $e');
    }
  }
}
