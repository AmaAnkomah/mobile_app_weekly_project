import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../services/firestore_service.dart';
import '../../widgets/order_card.dart';
import '../../widgets/rating_dialog.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final uid = authVM.user?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please log in')));
    }

    final firestoreService = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: firestoreService.streamUserOrders(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.error)));
          }

          final orders = snap.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.onSurfaceDim.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('No orders yet', style: TextStyle(fontSize: 18, color: AppTheme.onSurfaceDim)),
                  const SizedBox(height: 8),
                  const Text('Your order history will appear here', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: orders.length,
            itemBuilder: (_, i) {
              final order = orders[i];
              return OrderCard(
                order: order,
                onRate: (rating, comment) => _handleRate(context, order, uid, rating, comment),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleRate(
    BuildContext context, 
    OrderModel order, 
    String uid, 
    int rating, 
    String comment
  ) async {
    final firestoreService = context.read<FirestoreService>();
    try {
      await firestoreService.rateOrder(
        uid: uid,
        orderId: order.id,
        primaryItemId: order.items.isNotEmpty ? order.items.first.itemId : '',
        rating: rating,
        comment: comment,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for your feedback!'), backgroundColor: AppTheme.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rate: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}
