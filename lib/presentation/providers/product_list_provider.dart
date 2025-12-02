import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';
import '../../data/datasources/local/mock_data_source.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/product_repository.dart';

const _defaultMerchantId = 'demo-merchant';

final _logger = AppLogger.instance;

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProductRepository(supabase: client);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryRepository(supabase: client);
});

final mockDataSourceProvider = Provider<MockDataSource>((ref) {
  return MockDataSource();
});

final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final productRepository = ref.watch(productRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final mockDataSource = ref.watch(mockDataSourceProvider);

  return ProductListNotifier(
    merchantId: _defaultMerchantId,
    productRepository: productRepository,
    categoryRepository: categoryRepository,
    mockDataSource: mockDataSource,
  )..loadInitialData();
});

class ProductListState extends Equatable {
  static const _noChange = Object();

  final bool isLoading;
  final List<ProductModel> allProducts;
  final List<ProductModel> visibleProducts;
  final List<CategoryModel> categories;
  final String? errorMessage;
  final String? selectedCategoryId;
  final String searchKeyword;
  final bool showOnlyAvailable;
  final String merchantId;

  const ProductListState({
    required this.isLoading,
    required this.allProducts,
    required this.visibleProducts,
    required this.categories,
    required this.errorMessage,
    required this.selectedCategoryId,
    required this.searchKeyword,
    required this.showOnlyAvailable,
    required this.merchantId,
  });

  factory ProductListState.initial(String merchantId) {
    return ProductListState(
      isLoading: true,
      allProducts: const [],
      visibleProducts: const [],
      categories: const [],
      errorMessage: null,
      selectedCategoryId: null,
      searchKeyword: '',
      showOnlyAvailable: true,
      merchantId: merchantId,
    );
  }

  ProductListState copyWith({
    bool? isLoading,
    List<ProductModel>? allProducts,
    List<ProductModel>? visibleProducts,
    List<CategoryModel>? categories,
    Object? errorMessage = _noChange,
    String? selectedCategoryId,
    String? searchKeyword,
    bool? showOnlyAvailable,
    String? merchantId,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      allProducts: allProducts ?? this.allProducts,
      visibleProducts: visibleProducts ?? this.visibleProducts,
      categories: categories ?? this.categories,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      showOnlyAvailable: showOnlyAvailable ?? this.showOnlyAvailable,
      merchantId: merchantId ?? this.merchantId,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        allProducts,
        visibleProducts,
        categories,
        errorMessage,
        selectedCategoryId,
        searchKeyword,
        showOnlyAvailable,
        merchantId,
      ];
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  ProductListNotifier({
    required this.merchantId,
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
    required MockDataSource mockDataSource,
  })  : _productRepository = productRepository,
        _categoryRepository = categoryRepository,
        _mockDataSource = mockDataSource,
        super(ProductListState.initial(merchantId));

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final MockDataSource _mockDataSource;
  final String merchantId;

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categories = await _categoryRepository.getCategories(
        merchantId: merchantId,
      );

      final products = await _productRepository.getProducts(
        merchantId: merchantId,
        isAvailable: state.showOnlyAvailable ? true : null,
      );

      state = state.copyWith(
        isLoading: false,
        categories: categories,
        allProducts: products,
        visibleProducts: _applyFilters(
          products: products,
          categories: categories,
          selectedCategoryId: state.selectedCategoryId,
          keyword: state.searchKeyword,
          showOnlyAvailable: state.showOnlyAvailable,
        ),
      );
    } catch (error) {
      _logger.w('加载 Supabase 数据失败，使用离线样例数据: $error');
      final categories = _mockDataSource.getSampleCategories(merchantId);
      final products = _mockDataSource.getSampleProducts(
        merchantId: merchantId,
        categories: categories,
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: '无法连接到服务器，已使用离线示例数据',
        categories: categories,
        allProducts: products,
        visibleProducts: products,
      );
    }
  }

  Future<void> refresh() async {
    await loadInitialData();
  }

  Future<void> search(String keyword) async {
    state = state.copyWith(searchKeyword: keyword);

    if (keyword.isEmpty) {
      _updateVisibleProducts();
      return;
    }

    try {
      final results = await _productRepository.searchProducts(
        keyword,
        merchantId: merchantId,
      );

      state = state.copyWith(visibleProducts: results, errorMessage: null);
    } catch (_) {
      final filtered = state.allProducts
          .where((product) =>
              product.name.contains(keyword) ||
              (product.description?.contains(keyword) ?? false))
          .toList();

      state = state.copyWith(
        visibleProducts: filtered,
        errorMessage: '搜索功能离线模式下仅支持本地过滤',
      );
    }
  }

  void toggleAvailabilityFilter(bool value) {
    state = state.copyWith(showOnlyAvailable: value);
    _updateVisibleProducts();
  }

  void selectCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
    _updateVisibleProducts();
  }

  void _updateVisibleProducts() {
    final filtered = _applyFilters(
      products: state.allProducts,
      categories: state.categories,
      selectedCategoryId: state.selectedCategoryId,
      keyword: state.searchKeyword,
      showOnlyAvailable: state.showOnlyAvailable,
    );

    state = state.copyWith(visibleProducts: filtered);
  }

  List<ProductModel> _applyFilters({
    required List<ProductModel> products,
    required List<CategoryModel> categories,
    required String? selectedCategoryId,
    required String keyword,
    required bool showOnlyAvailable,
  }) {
    return products.where((product) {
      var matches = true;

      if (selectedCategoryId != null) {
        matches = matches && product.categoryId == selectedCategoryId;
      }

      if (keyword.isNotEmpty) {
        matches = matches &&
            (product.name.contains(keyword) ||
                (product.description?.contains(keyword) ?? false));
      }

      if (showOnlyAvailable) {
        matches = matches && product.isAvailable;
      }

      return matches;
    }).toList();
  }
}
