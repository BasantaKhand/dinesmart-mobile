class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:5001/api';
  // static const String baseUrl = 'http://localhost:5001/api';
  static const String baseUrl = 'http://192.168.101.7:5001/api';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';

  // ============ Waiter Dashboard Endpoints ============
  static const String tables = '/tables';
  static const String categories = '/categories';
  static const String menuItems = '/menu-items';
  static const String orders = '/orders';
  static String activeOrderByTable(String tableId) => '/orders/active/table/$tableId';
  static String appendItemsToOrder(String orderId) => '/orders/$orderId/append';
  static String markBillPrinted(String orderId) => '/orders/$orderId/mark-bill-printed';
  static String updateOrderStatus(String orderId) => '/orders/$orderId/status';

  // ============ Cashier Endpoints ============
  static const String paymentQueue = '/payment-queue';
  static const String paymentQueueStatus = '/payment-queue/status';
  static const String cashDrawerStatus = '/cash-drawer/status';
  static const String cashDrawerOpen = '/cash-drawer/open';
  static const String cashDrawerClose = '/cash-drawer/close';
  static const String cashDrawerHistory = '/cash-drawer/history';

  // ============ Audit / Settlement Endpoints ============
  static const String auditTransactions = '/audit/transactions';
  static const String auditMyTransactions = '/audit/my-transactions';
  static const String auditDailySettlement = '/audit/daily-settlement';
  static const String auditSettlements = '/audit/settlements';

  // ============ Staff Endpoints ============
  static const String staff = '/staff';
  static String staffById(String id) => '/staff/$id';
  static String toggleStaffStatus(String id) => '/staff/$id/status';
  static String resetStaffPassword(String id) => '/staff/$id/reset-password';

  // ============ User Endpoints ============
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => '/users/$id/photo';

  // ============ Dashboard Endpoints ============
  static const String dashboardOverview = '/dashboard/overview';
  static const String dashboardSalesOverview = '/dashboard/sales-overview';
  static const String dashboardCategorySales = '/dashboard/category-sales';

  // ============ Notification Endpoints ============
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String markNotificationRead(String id) => '/notifications/$id/read';
}
