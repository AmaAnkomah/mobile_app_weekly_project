import 'package:flutter/foundation.dart';
import '../models/menu_item_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

/// Drives the menu screen — real-time stream + local search/filter state.
///
/// WHY HOLD FILTER STATE HERE (NOT IN SCREEN)?
/// Moving filter state into the ViewModel means:
///   • Screen rebuilds are driven by a single notifyListeners() call.
///   • If the user navigates away and back, filter state persists.
///   • Unit-testable without a widget tree.
class MenuViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  MenuViewModel(this._firestoreService);

  // ── Filter state (Advanced C) ────────────────────────────────────────────────
  String _searchQuery     = '';
  String? _selectedCategory;       // null = "All"
  double _maxPrice        = AppConstants.maxMenuPrice;

  String  get searchQuery       => _searchQuery;
  String? get selectedCategory  => _selectedCategory;
  double  get maxPrice          => _maxPrice;

  // ── Real-time menu stream ────────────────────────────────────────────────────
  /// The raw Firestore stream; widgets wrap this in a StreamBuilder.
  Stream<List<MenuItemModel>> get menuStream => _firestoreService.streamMenu();

  /// Apply client-side filters to a snapshot list from the stream.
  List<MenuItemModel> applyFilters(List<MenuItemModel> all) {
    var result = all;

    // Search by name (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((item) => item.name.toLowerCase().contains(q)).toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      result = result.where((item) => item.category == _selectedCategory).toList();
    }

    // Max price filter
    result = result.where((item) => item.price <= _maxPrice).toList();

    return result;
  }

  // ── Filter Mutators ──────────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _maxPrice = AppConstants.maxMenuPrice;
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _maxPrice < AppConstants.maxMenuPrice;

  // ── Category Helper ──────────────────────────────────────────────────────────
  List<String> get categories => AppConstants.categories;
}
