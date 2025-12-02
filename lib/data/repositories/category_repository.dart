import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';

class CategoryRepository {
  final SupabaseClient? _supabase;

  CategoryRepository({SupabaseClient? supabase}) : _supabase = supabase;

  SupabaseClient get _client {
    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase 未初始化');
    }
    return client;
  }

  Future<List<CategoryModel>> getCategories({required String merchantId}) async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('merchant_id', merchantId)
          .order('display_order');

      return (response as List)
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('获取分类失败: $e');
    }
  }
}
