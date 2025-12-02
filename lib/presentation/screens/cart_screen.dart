import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/cart_item.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cart),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _CartItemTile(item: item);
                    },
                  ),
                ),
                _buildSummary(total, () {
                  _showCheckoutDialog(context, total);
                }),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            AppStrings.cartEmpty,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(double total, VoidCallback onCheckout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.totalAmount,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  Validators.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text(AppStrings.checkout),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认下单'),
        content: Text('是否确认下单？总金额 ${Validators.formatCurrency(total)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('下单功能待接入 Supabase API')),
              );
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(Validators.formatCurrency(item.product.price)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () =>
                    notifier.updateQuantity(item.product.id, item.quantity - 1),
              ),
              Text('${item.quantity}'),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () =>
                    notifier.updateQuantity(item.product.id, item.quantity + 1),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notifier.removeItem(item.product.id),
          )
        ],
      ),
    );
  }
}
