import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../utils/app_theme.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = item.isOutOfStock;
    final isLowStock = item.isLowStock;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              _buildImage(),
              
              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStockBadge(isOutOfStock, isLowStock),
                          if (item.ratingCount > 0) _buildRatingBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.name, 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description, 
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceDim, height: 1.4),
                      ),
                      const Spacer(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GHS ${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppTheme.primary, 
                              fontSize: 18, 
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          _buildAddButton(context, isOutOfStock),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() => SizedBox(
    width: 140,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppTheme.surfaceAlt,
            child: const Icon(Icons.restaurant, color: AppTheme.onSurfaceDim, size: 40),
          ),
        ),
        // Gradient overlay for depth
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.black12],
            ),
          ),
        ),
        if (item.isOutOfStock)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Text(
                'OUT OF STOCK',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildStockBadge(bool outOfStock, bool lowStock) {
    Color color = AppTheme.success;
    String label = 'In Stock';
    if (outOfStock) {
      color = AppTheme.error;
      label = 'Out of Stock';
    } else if (lowStock) {
      color = AppTheme.warning;
      label = 'Only ${item.stock} left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), 
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(), 
        style: TextStyle(
          color: color, 
          fontSize: 9, 
          fontWeight: FontWeight.w900, 
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildRatingBadge() => Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 14),
      const SizedBox(width: 4),
      Text(
        item.averageRating.toStringAsFixed(1), 
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ],
  );

  Widget _buildAddButton(BuildContext context, bool outOfStock) => InkWell(
    onTap: outOfStock ? null : onAddToCart,
    borderRadius: BorderRadius.circular(14),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: outOfStock ? AppTheme.surfaceAlt : AppTheme.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: outOfStock ? null : [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        outOfStock ? Icons.not_interested : Icons.add_shopping_cart,
        color: outOfStock ? AppTheme.onSurfaceDim : Colors.white,
        size: 20,
      ),
    ),
  );
}
