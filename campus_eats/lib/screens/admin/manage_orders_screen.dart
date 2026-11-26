import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../viewmodels/admin_viewmodel.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: adminVM.streamAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.onSurfaceDim),
                  SizedBox(height: 16),
                  Text('No orders placed yet.', style: TextStyle(color: AppTheme.onSurfaceDim)),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderManagementCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderManagementCard extends StatelessWidget {
  final OrderModel order;
  const _OrderManagementCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.read<AdminViewModel>();
    final dateStr = order.timestamp != null 
        ? DateFormat('HH:mm - dd MMM').format(order.timestamp!) 
        : 'Pending...';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(order.status).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.userEmail ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(dateStr, style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 12)),
          const Divider(height: 24),
          
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text('${item.quantity}x', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text(item.name, style: const TextStyle(color: AppTheme.onSurface)),
              ],
            ),
          )),
          
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: GHS ${order.total.toStringAsFixed(2)}', 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              _buildActions(context, adminVM),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AdminViewModel vm) {
    if (order.status == AppConstants.statusCompleted) return const Icon(Icons.check_circle, color: AppTheme.success);

    String nextLabel = '';
    String nextStatus = '';
    
    if (order.status == AppConstants.statusPending) {
      nextLabel = 'Prepare';
      nextStatus = AppConstants.statusPreparing;
    } else if (order.status == AppConstants.statusPreparing) {
      nextLabel = 'Ready';
      nextStatus = AppConstants.statusReady;
    } else if (order.status == AppConstants.statusReady) {
      nextLabel = 'Complete';
      nextStatus = AppConstants.statusCompleted;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 36),
        backgroundColor: _getStatusColor(nextStatus),
      ),
      onPressed: () => vm.updateStatus(order.id!, order.uid ?? '', nextStatus),
      child: Text(nextLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:   return AppTheme.warning;
      case AppConstants.statusPreparing: return Colors.blue;
      case AppConstants.statusReady:     return AppTheme.success;
      case AppConstants.statusCompleted: return AppTheme.onSurfaceDim;
      default:                           return AppTheme.primary;
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
