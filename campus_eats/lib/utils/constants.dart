/// Centralised constants — change collection names here only.
class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ── Firestore Collection Names ───────────────────────────────────────────────
  static const String usersCollection   = 'users';
  static const String menuCollection    = 'menu';
  static const String ordersCollection  = 'orders'; // Admin-accessible global mirror
  static const String userOrdersSub     = 'orders'; // users/{uid}/orders subcollection

  // ── Hive Box Names ───────────────────────────────────────────────────────────
  static const String cartBox           = 'cart_box';

  // ── Hive TypeAdapter IDs ──────────────────────────────────────────────────────
  static const int cartItemTypeId       = 0;

  // ── Order Statuses ───────────────────────────────────────────────────────────
  static const String statusPending     = 'pending';
  static const String statusPreparing   = 'preparing';
  static const String statusReady       = 'ready';
  static const String statusCompleted   = 'completed';

  static const List<String> orderStatuses = [
    statusPending,
    statusPreparing,
    statusReady,
    statusCompleted,
  ];

  // ── Menu Categories ───────────────────────────────────────────────────────────
  static const String catBreakfast = 'Breakfast';
  static const String catLunch     = 'Lunch';
  static const String catSnacks    = 'Snacks';

  static const List<String> categories = [
    catBreakfast,
    catLunch,
    catSnacks,
  ];

  // ── Stock Alert Threshold ─────────────────────────────────────────────────────
  /// Items with stock <= this value trigger a warning badge on admin dashboard
  static const int stockAlertThreshold = 5;

  // ── Price Slider Bounds (GHS) ─────────────────────────────────────────────────
  static const double minMenuPrice     = 0;
  static const double maxMenuPrice     = 200;

  // ── UI Strings ────────────────────────────────────────────────────────────────
  static const String appName          = 'Campus Eats';
  static const String appSubtitle      = 'VVU Cafeteria';
  static const String currencySymbol   = 'GHS';
  static const String currency         = 'GHS ';
}
