import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/cart_item_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../widgets/menu_item_card.dart';
import '../../widgets/category_chip.dart';

/// Main browsing screen. Uses a StreamBuilder on the Firestore menu stream.
/// Client-side filtering (search, category, max-price) is applied via MenuViewModel.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _searchCtrl = TextEditingController();
  bool _showPriceFilter = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuVM = context.watch<MenuViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, menuVM),
          _buildSearchAndFilters(context, menuVM),
          _buildMenuList(menuVM),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MenuViewModel menuVM) =>
      SliverAppBar(
        expandedHeight: 120,
        floating: true,
        snap: true,
        pinned: false,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Campus Eats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.onBackground)),
              const Text('VVU Cafeteria Menu', style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceDim)),
            ],
          ),
        ),
        actions: [
          if (menuVM.hasActiveFilters)
            TextButton(
              onPressed: () {
                menuVM.clearFilters();
                _searchCtrl.clear();
              },
              child: const Text('Clear', style: TextStyle(color: AppTheme.primary)),
            ),
          const SizedBox(width: 8),
        ],
      );

  Widget _buildSearchAndFilters(BuildContext context, MenuViewModel menuVM) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchCtrl,
                onChanged: menuVM.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search menu items...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceDim),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.onSurfaceDim),
                          onPressed: () { _searchCtrl.clear(); menuVM.setSearchQuery(''); },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryChipWidget(
                      label: 'All',
                      isSelected: menuVM.selectedCategory == null,
                      onTap: () => menuVM.setCategory(null),
                    ),
                    ...AppConstants.categories.map((cat) => CategoryChipWidget(
                      label: cat,
                      color: AppTheme.categoryColor(cat),
                      isSelected: menuVM.selectedCategory == cat,
                      onTap: () => menuVM.setCategory(cat),
                    )),
                    // Price filter toggle
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text('GHS ≤ ${menuVM.maxPrice.toInt()}'),
                      selected: _showPriceFilter || menuVM.maxPrice < AppConstants.maxMenuPrice,
                      onSelected: (_) => setState(() => _showPriceFilter = !_showPriceFilter),
                      avatar: const Icon(Icons.tune, size: 16),
                    ),
                  ],
                ),
              ),
              // Price slider (Advanced C)
              if (_showPriceFilter) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Max price:', style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13)),
                    Expanded(
                      child: Slider(
                        value: menuVM.maxPrice,
                        min: AppConstants.minMenuPrice,
                        max: AppConstants.maxMenuPrice,
                        divisions: 20,
                        label: 'GHS ${menuVM.maxPrice.toInt()}',
                        activeColor: AppTheme.primary,
                        inactiveColor: AppTheme.surfaceAlt,
                        onChanged: menuVM.setMaxPrice,
                      ),
                    ),
                    SizedBox(
                      width: 56,
                      child: Text('GHS ${menuVM.maxPrice.toInt()}',
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildMenuList(MenuViewModel menuVM) => StreamBuilder<List<MenuItemModel>>(
    stream: menuVM.menuStream,
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        );
      }
      if (snap.hasError) {
        return SliverFillRemaining(
          child: Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: AppTheme.error))),
        );
      }

      final allItems = snap.data ?? [];
      final filtered = menuVM.applyFilters(allItems);

      if (filtered.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, color: AppTheme.onSurfaceDim, size: 56),
                const SizedBox(height: 12),
                Text(
                  allItems.isEmpty ? 'No menu items yet' : 'No items match your search',
                  style: const TextStyle(color: AppTheme.onSurfaceDim, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      }

      // Group by category for the list header
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = filtered[index];
              // Show category header when category changes
              final showHeader = index == 0 || filtered[index - 1].category != item.category;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) ...[
                    if (index != 0) const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4, height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.categoryColor(item.category),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item.category,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.categoryColor(item.category))),
                        ],
                      ),
                    ),
                  ],
                  MenuItemCard(
                    item: item,
                    onAddToCart: () => _addToCart(context, item),
                  ),
                ],
              );
            },
            childCount: filtered.length,
          ),
        ),
      );
    },
  );

  void _addToCart(BuildContext context, MenuItemModel item) {
    if (item.isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item is out of stock'), backgroundColor: AppTheme.error),
      );
      return;
    }
    final cartVM = context.read<CartViewModel>();
    cartVM.addItem(CartItemModel(
      itemId:   item.id,
      name:     item.name,
      price:    item.price,
      quantity: 1,
      imageUrl: item.imageUrl,
      stock:    item.stock,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        action: SnackBarAction(label: 'View Cart', textColor: AppTheme.primary, onPressed: () {}),
      ),
    );
  }
}
