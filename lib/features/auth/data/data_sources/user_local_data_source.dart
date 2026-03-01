import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/services/hive/hive_service.dart';
import '../models/user_hive_model.dart';

final userLocalDataSourceProvider = Provider((ref) {
  return UserLocalDataSource(ref.read(hiveServiceProvider));
});

class UserLocalDataSource {
  final HiveService _hiveService;

  UserLocalDataSource(this._hiveService);

  UserHiveModel? getCurrentUser() {
    if (_hiveService.userBox.isEmpty) return null;
    return _hiveService.userBox.values.first;
  }

  Future<void> saveUser(UserHiveModel user) async {
    await _hiveService.userBox.clear();
    await _hiveService.userBox.put(user.id, user);
  }

  Future<void> updateUser(UserHiveModel user) async {
    await _hiveService.userBox.put(user.id, user);
  }

  Future<void> clearUser() async {
    await _hiveService.userBox.clear();
  }

  bool hasUser() {
    return _hiveService.userBox.isNotEmpty;
  }
}
