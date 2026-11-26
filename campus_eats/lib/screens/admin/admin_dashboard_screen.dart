import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'manage_menu_screen.dart';
import 'manage_orders_screen.dart';
import '../student/home_screen.dart';
import '../../models/order_model.dart';
import '../../models/menu_item_model.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafeteria Admin'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
            icon: const Icon(Icons.swap_horiz, color: AppTheme.primary),
            label: const Text('Student View', style: TextStyle(color: AppTheme.primary)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authVM.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(authVM.user?.email ?? 'Admin'),
            const SizedBox(height: 32),
            
            // Stats Row
            StreamBuilder<List<OrderModel>>(
              stream: adminVM.streamAllOrders(),
              builder: (context, snapshot) {
                final orders = snapshot.data ?? [];
                final pendingCount = orders.where((o) => o.status == AppConstants.statusPending || o.status == AppConstants.statusPreparing).length;
                final readyCount = orders.where((o) => o.status == AppConstants.statusReady).length;

                return Row(
                  children: [
                    Expanded(child: _buildStatCard('Active', pendingCount.toString(), Icons.timer, AppTheme.warning)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('Ready', readyCount.toString(), Icons.check_circle_outline, AppTheme.success)),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),

            const Text('Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildAdminTile(
              context,
              title: 'Manage Orders',
              subtitle: 'Process and update order status',
              icon: Icons.receipt_long,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageOrdersScreen()),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildAdminTile(
              context,
              title: 'Manage Menu',
              subtitle: 'Add or edit food items and stock',
              icon: Icons.restaurant_menu,
              color: AppTheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageMenuScreen()),
              ),
            ),
            const SizedBox(height: 32),

            // Stock Alerts Section (If any)
            const Text('Inventory Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            StreamBuilder<List<MenuItemModel>>(
              stream: adminVM.streamMenu(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                final lowStock = items.where((i) => i.isLowStock || i.isOutOfStock).toList();

                if (lowStock.isEmpty) {
                  return _buildNoAlertsPlaceholder();
                }

                return Column(
                  children: lowStock.map((item) => _buildLowStockCard(item)).toList(),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String email) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Welcome back,', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 16)),
      Text(email, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary)),
    ],
  );

  Widget _buildStatCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 14)),
      ],
    ),
  );

  Widget _buildAdminTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(subtitle, style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.onSurfaceDim),
        ],
      ),
    ),
  );

  Widget _buildNoAlertsPlaceholder() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppTheme.surfaceAlt,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.onSurfaceDim.withOpacity(0.1)),
    ),
    child: const Center(
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppTheme.onSurfaceDim, size: 40),
          SizedBox(height: 12),
          Text('All items are in stock', style: TextStyle(color: AppTheme.onSurfaceDim)),
        ],
      ),
    ),
  );

  Widget _buildLowStockCard(MenuItemModel item) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: item.isOutOfStock ? AppTheme.error.withOpacity(0.1) : AppTheme.warning.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: item.isOutOfStock ? AppTheme.error.withOpacity(0.3) : AppTheme.warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(
          item.isOutOfStock ? Icons.error_outline : Icons.warning_amber_rounded,
          color: item.isOutOfStock ? AppTheme.error : AppTheme.warning,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                item.isOutOfStock ? 'OUT OF STOCK' : 'Only ${item.stock} left in stock',
                style: TextStyle(
                  color: item.isOutOfStock ? AppTheme.error : AppTheme.warning,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.edit, size: 16, color: AppTheme.onSurfaceDim),
      ],
    ),
  );
}
