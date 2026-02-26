import 'package:dinesmart_app/core/services/hive/hive_service.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:dinesmart_app/features/auth/data/models/auth_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authLocalDatasourceProvider = Provider<ILocalAuthDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements ILocalAuthDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({required HiveService hiveService, required UserSessionService userSessionService})
      : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    
    final user = await _hiveService.login(email, password);
    if (user != null && user.authId != null) {
        // Save user session to SharedPreferences : Pachi app restart vayo vani pani user logged in rahos
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          role: 'WAITER', // Default role for local db users
          phoneNumber: user.phoneNumber,
          profilePicture: user.profilePicture,
        );
        return user;
      }
      return null;
    
  }

  @override
  Future<bool> logout() async{
    await _userSessionService.clearSession();
    return true;
  }

  @override
  Future<AuthHiveModel?> register(AuthHiveModel model) async {
    final response = await _hiveService.register(model);
    return response;
  }
  
  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    return _hiveService.getUserByEmail(email);

  }


}