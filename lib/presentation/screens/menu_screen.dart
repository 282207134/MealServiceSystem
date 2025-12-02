import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_list_provider.dart';
import '../widgets/product_card.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productListState = ref.watch(productListProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('校园点餐'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => context.push('/cart'),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
      body: productListState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildCategoryTabs(productListState),
                if (productListState.errorMessage != null)
                  _buildErrorBanner(productListState.errorMessage!),
                Expanded(child: _buildProductGrid(productListState)),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索商品',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(productListProvider.notifier).search('');
                  },
                )
              : null,
        ),
        onChanged: (value) {
          ref.read(productListProvider.notifier).search(value);
        },
      ),
    );
  }

  Widget _buildCategoryTabs(ProductListState state) {
    if (state.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(
            label: '全部',
            isSelected: state.selectedCategoryId == null,
            onTap: () {
              ref.read(productListProvider.notifier).selectCategory(null);
            },
          ),
          ...state.categories.map(
            (category) => _buildCategoryChip(
              label: category.name,
              isSelected: state.selectedCategoryId == category.id,
              onTap: () {
                ref
                    .read(productListProvider.notifier)
                    .selectCategory(category.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withOpacity(0.2),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductListState state) {
    if (state.visibleProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '暂无商品',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(productListProvider.notifier).refresh();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.visibleProducts.length,
        itemBuilder: (context, index) {
          final product = state.visibleProducts[index];
          return ProductCard(
            product: product,
            onTap: () => _onProductTap(product),
            onAddToCart: () => _onAddToCart(product),
          );
        },
      ),
    );
  }

  void _onProductTap(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.description != null)
              Text(product.description!),
            const SizedBox(height: 16),
            Text(
              '¥${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          if (product.isAvailable)
            ElevatedButton(
              onPressed: () {
                _onAddToCart(product);
                Navigator.pop(context);
              },
              child: const Text('加入购物车'),
            ),
        ],
      ),
    );
  }

  void _onAddToCart(ProductModel product) {
    ref.read(cartProvider.notifier).addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} 已加入购物车'),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: '查看',
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }
}
