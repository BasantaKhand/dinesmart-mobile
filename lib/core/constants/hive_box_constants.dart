class HiveBoxConstants {
  HiveBoxConstants._();

  static const String dbName = 'dine_smart_db';

  static const int authTypeId = 0;
  static const String authBox = 'auth_box';

  static const int userTypeId = 1;
  static const String userBox = 'user_box';

  static const int categoryTypeId = 2;
  static const String categoryBox = 'category_box';

  static const int menuItemTypeId = 3;
  static const String menuItemBox = 'menu_item_box';

  static const int tableTypeId = 4;
  static const String tableBox = 'table_box';

  static const int orderTypeId = 5;
  static const String orderBox = 'order_box';

  static const int orderItemTypeId = 6;
  static const String activeOrderBox = 'active_order_box';

  static const int pendingOperationTypeId = 7;
  static const String pendingOperationBox = 'pending_operation_box';

  static const int cashierDashboardTypeId = 8;
  static const String cashierDashboardBox = 'cashier_dashboard_box';

  // Admin Dashboard cache (JSON string box)
  static const String adminDashboardBox = 'admin_dashboard_box';

  // Staff Management cache (JSON string box)
  static const String staffBox = 'staff_box';

  // Notifications cache (JSON string box)
  static const String notificationsBox = 'notifications_box';

  static const String cacheTimestampBox = 'cache_timestamp_box';

  static const String categoryCacheKey = 'categories_last_updated';
  static const String menuItemsCacheKey = 'menu_items_last_updated';
  static const String tablesCacheKey = 'tables_last_updated';
  static const String ordersCacheKey = 'orders_last_updated';
  static const String cashierDashboardCacheKey = 'cashier_dashboard_last_updated';
  static const String adminDashboardCacheKey = 'admin_dashboard_last_updated';
  static const String staffCacheKey = 'staff_last_updated';
  static const String notificationsCacheKey = 'notifications_last_updated';

  static const Duration cacheValidDuration = Duration(hours: 24);
  static const Duration tableCacheValidDuration = Duration(minutes: 5);
  static const Duration orderCacheValidDuration = Duration(minutes: 2);
  static const Duration cashierDashboardCacheValidDuration = Duration(minutes: 2);
  static const Duration adminDashboardCacheValidDuration = Duration(minutes: 5);
  static const Duration staffCacheValidDuration = Duration(minutes: 10);
  static const Duration notificationsCacheValidDuration = Duration(minutes: 3);
}