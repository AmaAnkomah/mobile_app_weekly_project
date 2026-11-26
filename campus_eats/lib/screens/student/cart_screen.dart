import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/cart_item_tile.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVM  = context.watch<CartViewModel>();
    final authVM  = context.watch<AuthViewModel>();
    final orderVM = context.watch<OrderViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (!cartVM.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cartVM),
              child: const Text('Clear All', style: TextStyle(color: AppTheme.error)),
            ),
        ],
      ),
      body: cartVM.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: cartVM.items.length,
                    itemBuilder: (_, i) => CartItemTile(
                      item: cartVM.items[i],
                      onIncrement: () => cartVM.updateQuantity(
                          cartVM.items[i].itemId, cartVM.items[i].quantity + 1),
                      onDecrement: () => cartVM.updateQuantity(
                          cartVM.items[i].itemId, cartVM.items[i].quantity - 1),
                      onRemove: () => cartVM.removeItem(cartVM.items[i].itemId),
                    ),
                  ),
                ),
                _buildOrderSummary(context, cartVM, orderVM, authVM),
              ],
            ),
    );
  }

  Widget _buildEmptyCart() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.onSurfaceDim.withValues(alpha: 0.4)),
        const SizedBox(height: 16),
        const Text('Your cart is empty', style: TextStyle(fontSize: 18, color: AppTheme.onSurfaceDim)),
        const SizedBox(height: 8),
        const Text('Browse the menu and add items', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
      ],
    ),
  );

  Widget _buildOrderSummary(
    BuildContext context,
    CartViewModel cartVM,
    OrderViewModel orderVM,
    AuthViewModel authVM,
  ) {
    final fmt = NumberFormat.currency(symbol: 'GHS ', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cartVM.itemCount} item(s)', style: const TextStyle(color: AppTheme.onSurfaceDim)),
              Text(fmt.format(cartVM.total),
                  style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          if (orderVM.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(orderVM.errorMessage!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppTheme.error),
                    onPressed: orderVM.clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: orderVM.isLoading ? null : () => _placeOrder(context, cartVM, orderVM, authVM),
            child: orderVM.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartViewModel cartVM,
    OrderViewModel orderVM,
    AuthViewModel authVM,
  ) async {
    final user = authVM.user;
    if (user == null) return;

    final ok = await orderVM.placeOrder(
      uid:       user.uid,
      email:     user.email,
      cartItems: cartVM.items,
    );

    if (ok) {
      await cartVM.clearCart();
      orderVM.resetSuccess();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed! We\'re preparing your food 🍽️'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, CartViewModel cartVM) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true) cartVM.clearCart();
  }
}
