import 'package:uuid/uuid.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';

class MockDataSource {
  MockDataSource()
      : _uuid = const Uuid(),
        seedTime = DateTime.now();

  final Uuid _uuid;
  final DateTime seedTime;

  List<CategoryModel> getSampleCategories(String merchantId) {
    return [
      CategoryModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        name: '人气推荐',
        displayOrder: 0,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      CategoryModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        name: '汉堡套餐',
        displayOrder: 1,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      CategoryModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        name: '甜品饮料',
        displayOrder: 2,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
    ];
  }

  List<ProductModel> getSampleProducts({
    required String merchantId,
    required List<CategoryModel> categories,
  }) {
    final popularCategory = categories.first;
    final burgerCategory = categories[1];
    final dessertCategory = categories[2];

    return [
      ProductModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        categoryId: popularCategory.id,
        name: '香辣鸡腿堡套餐',
        description: '含薯条+可乐，经典人气套餐',
        price: 28,
        imageUrl:
            'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=600&q=80',
        isAvailable: true,
        stockQuantity: 50,
        displayOrder: 0,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      ProductModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        categoryId: burgerCategory.id,
        name: '双层牛肉堡套餐',
        description: '双层牛肉+芝士，满足肉食爱好者',
        price: 32,
        imageUrl:
            'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=600&q=80',
        isAvailable: true,
        stockQuantity: 35,
        displayOrder: 1,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      ProductModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        categoryId: burgerCategory.id,
        name: '香烤鸡腿堡',
        description: '精选鸡腿肉，外酥里嫩',
        price: 24,
        imageUrl:
            'https://images.unsplash.com/photo-1478145046317-39f10e56b5e9?auto=format&fit=crop&w=600&q=80',
        isAvailable: true,
        stockQuantity: 40,
        displayOrder: 2,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      ProductModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        categoryId: dessertCategory.id,
        name: '草莓圣代',
        description: '清爽圣代，甜蜜加倍',
        price: 12,
        imageUrl:
            'https://images.unsplash.com/photo-1464306076886-da185f6a9d12?auto=format&fit=crop&w=600&q=80',
        isAvailable: true,
        stockQuantity: 60,
        displayOrder: 0,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
      ProductModel(
        id: _uuid.v4(),
        merchantId: merchantId,
        categoryId: dessertCategory.id,
        name: '香芋派',
        description: '酥脆外皮，香甜内馅',
        price: 10,
        imageUrl:
            'https://images.unsplash.com/photo-1547043638-421c02b5e057?auto=format&fit=crop&w=600&q=80',
        isAvailable: true,
        stockQuantity: 80,
        displayOrder: 1,
        createdAt: seedTime,
        updatedAt: seedTime,
      ),
    ];
  }
}
