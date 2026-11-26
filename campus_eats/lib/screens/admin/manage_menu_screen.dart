import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../utils/app_theme.dart';
import '../../viewmodels/admin_viewmodel.dart';
import 'add_edit_item_screen.dart';

class ManageMenuScreen extends StatelessWidget {
  const ManageMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
        ),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: adminVM.streamMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No menu items found.'));
          }

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _MenuItemTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItemModel item;
  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.read<AdminViewModel>();
    final isLowStock = item.stock < 5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 70, height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70, height: 70,
                color: AppTheme.surfaceAlt,
                child: const Icon(Icons.fastfood, color: AppTheme.onSurfaceDim),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('GHS ${item.price.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    _buildStockBadge(isLowStock),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.onSurfaceDim),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditItemScreen(item: item)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _confirmDelete(context, adminVM),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(bool isLow) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: (isLow ? AppTheme.error : AppTheme.success).withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      'Stock: ${item.stock}',
      style: TextStyle(
        color: isLow ? AppTheme.error : AppTheme.success,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  void _confirmDelete(BuildContext context, AdminViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to remove "${item.name}" from the menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              vm.deleteItem(item.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
