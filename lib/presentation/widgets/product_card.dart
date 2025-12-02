import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildName(),
                    const SizedBox(height: 4),
                    _buildDescription(),
                    const Spacer(),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          if (product.imageUrl != null)
            CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          if (!product.isAvailable)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text(
                  '已售罄',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.fastfood,
        size: 48,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildName() {
    return Text(
      product.name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    if (product.description == null) {
      return const SizedBox.shrink();
    }

    return Text(
      product.description!,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          Validators.formatCurrency(product.price),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        if (onAddToCart != null && product.isAvailable)
          IconButton(
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart),
            color: AppColors.primary,
            tooltip: '加入购物车',
          ),
      ],
    );
  }
}
