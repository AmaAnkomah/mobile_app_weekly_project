import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'rating_dialog.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(int, String) onRate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = order.timestamp != null 
        ? DateFormat('dd MMM, HH:mm').format(order.timestamp!) 
        : 'Pending...';
    
    final isCompleted = order.status == AppConstants.statusCompleted;
    final isRated = order.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(order.status).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13, fontWeight: FontWeight.w600)),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${item.quantity}x ${item.name}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )),
          
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: GHS ${order.total.toStringAsFixed(2)}', 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (isCompleted && !isRated)
                TextButton.icon(
                  icon: const Icon(Icons.star_outline, size: 18),
                  label: const Text('Rate'),
                  onPressed: () => _showRatingDialog(context),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              if (isRated)
                _buildRatingResult(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingResult() => Row(
    children: [
      const Icon(Icons.star, color: Colors.amber, size: 16),
      const SizedBox(width: 4),
      Text('${order.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RatingDialog(
        onSubmitted: (rating, comment) => onRate(rating, comment),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:   return AppTheme.warning;
      case AppConstants.statusPreparing: return Colors.blue;
      case AppConstants.statusReady:     return AppTheme.success;
      default:                           return AppTheme.onSurfaceDim;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
       case AppConstants.statusPending:   color = AppTheme.warning; break;
      case AppConstants.statusPreparing: color = Colors.blue; break;
      case AppConstants.statusReady:     color = AppTheme.success; break;
      default:                           color = AppTheme.onSurfaceDim;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}
