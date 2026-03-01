import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import 'package:dinesmart_app/features/auth/data/models/auth_hive_model.dart';
import 'package:dinesmart_app/features/auth/data/models/user_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/category_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/menu_item_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/table_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/order_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/pending_operation_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveBoxConstants.dbName}';
    Hive.init(path);

    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveBoxConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.categoryTypeId)) {
      Hive.registerAdapter(CategoryHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.menuItemTypeId)) {
      Hive.registerAdapter(MenuItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.tableTypeId)) {
      Hive.registerAdapter(TableHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.orderTypeId)) {
      Hive.registerAdapter(OrderHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.orderItemTypeId)) {
      Hive.registerAdapter(OrderItemHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveBoxConstants.pendingOperationTypeId)) {
      Hive.registerAdapter(PendingOperationHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveBoxConstants.authBox);
    await Hive.openBox<UserHiveModel>(HiveBoxConstants.userBox);
    await Hive.openBox<CategoryHiveModel>(HiveBoxConstants.categoryBox);
    await Hive.openBox<MenuItemHiveModel>(HiveBoxConstants.menuItemBox);
    await Hive.openBox<TableHiveModel>(HiveBoxConstants.tableBox);
    await Hive.openBox<OrderHiveModel>(HiveBoxConstants.orderBox);
    await Hive.openBox<OrderHiveModel>(HiveBoxConstants.activeOrderBox);
    await Hive.openBox<PendingOperationHiveModel>(HiveBoxConstants.pendingOperationBox);
    await Hive.openBox<DateTime>(HiveBoxConstants.cacheTimestampBox);
  }

  Future<void> closeHive() async {
    await Hive.close();
  }

  Future<void> clearAllData() async {
    await Hive.box<AuthHiveModel>(HiveBoxConstants.authBox).clear();
    await Hive.box<UserHiveModel>(HiveBoxConstants.userBox).clear();
    await Hive.box<CategoryHiveModel>(HiveBoxConstants.categoryBox).clear();
    await Hive.box<MenuItemHiveModel>(HiveBoxConstants.menuItemBox).clear();
    await Hive.box<TableHiveModel>(HiveBoxConstants.tableBox).clear();
    await Hive.box<OrderHiveModel>(HiveBoxConstants.orderBox).clear();
    await Hive.box<OrderHiveModel>(HiveBoxConstants.activeOrderBox).clear();
    await Hive.box<PendingOperationHiveModel>(HiveBoxConstants.pendingOperationBox).clear();
    await Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox).clear();
  }

  Box<AuthHiveModel> get authBox => Hive.box<AuthHiveModel>(HiveBoxConstants.authBox);
  Box<UserHiveModel> get userBox => Hive.box<UserHiveModel>(HiveBoxConstants.userBox);
  Box<CategoryHiveModel> get categoryBox => Hive.box<CategoryHiveModel>(HiveBoxConstants.categoryBox);
  Box<MenuItemHiveModel> get menuItemBox => Hive.box<MenuItemHiveModel>(HiveBoxConstants.menuItemBox);
  Box<TableHiveModel> get tableBox => Hive.box<TableHiveModel>(HiveBoxConstants.tableBox);
  Box<OrderHiveModel> get orderBox => Hive.box<OrderHiveModel>(HiveBoxConstants.orderBox);
  Box<OrderHiveModel> get activeOrderBox => Hive.box<OrderHiveModel>(HiveBoxConstants.activeOrderBox);
  Box<PendingOperationHiveModel> get pendingOperationBox => Hive.box<PendingOperationHiveModel>(HiveBoxConstants.pendingOperationBox);
  Box<DateTime> get cacheTimestampBox => Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox);

  bool isCacheValid(String cacheKey, {Duration? validDuration}) {
    final timestamp = cacheTimestampBox.get(cacheKey);
    if (timestamp == null) return false;
    final duration = validDuration ?? HiveBoxConstants.cacheValidDuration;
    return DateTime.now().difference(timestamp) < duration;
  }

  void updateCacheTimestamp(String cacheKey) {
    cacheTimestampBox.put(cacheKey, DateTime.now());
  }

  void invalidateCache(String cacheKey) {
    cacheTimestampBox.delete(cacheKey);
  }

  // Auth methods for local authentication
  Future<AuthHiveModel?> login(String email, String password) async {
    final users = authBox.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase() && user.password == password,
    );
    return users.isNotEmpty ? users.first : null;
  }

  Future<AuthHiveModel?> register(AuthHiveModel model) async {
    // Check if user already exists
    final existingUser = await getUserByEmail(model.email);
    if (existingUser != null) {
      return null; // User already exists
    }
    
    // Generate a unique ID if not provided
    final id = model.authId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final userWithId = AuthHiveModel(
      authId: id,
      email: model.email,
      password: model.password,
      fullName: model.fullName,
      username: model.username,
      phoneNumber: model.phoneNumber,
      profilePicture: model.profilePicture,
    );
    
    await authBox.put(id, userWithId);
    return userWithId;
  }

  Future<AuthHiveModel?> getUserByEmail(String email) async {
    final users = authBox.values.where(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );
    return users.isNotEmpty ? users.first : null;
  }
}