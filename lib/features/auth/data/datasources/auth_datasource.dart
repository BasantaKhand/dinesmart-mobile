import 'package:dinesmart_app/features/auth/data/models/auth_api_model.dart';
import 'package:dinesmart_app/features/auth/data/models/auth_hive_model.dart';

abstract interface class ILocalAuthDatasource {
  Future<AuthHiveModel?> register(AuthHiveModel model);
  Future<AuthHiveModel?> login(String email, String password);
  Future<bool> logout();
  Future<AuthHiveModel?> getUserByEmail(String email);
}

abstract interface class IRemoteAuthDatasource {
  Future<bool> sendRequest(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<bool> logout();
  Future<AuthApiModel?> getUserByEmail(String email);
  Future<bool> changePassword(String currentPassword, String newPassword);
  Future<AuthApiModel?> updateProfile({String? ownerName, String? phoneNumber, String? profilePicture});
}
