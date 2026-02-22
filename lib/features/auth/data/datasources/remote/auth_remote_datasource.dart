import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:dinesmart_app/features/auth/data/models/auth_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<IRemoteAuthDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthRemoteDatasource(
    apiClient: apiClient,
    userSessionService: userSessionService,
  );
});

class AuthRemoteDatasource implements IRemoteAuthDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService;

  @override
  Future<bool> sendRequest(AuthApiModel model) async {
    final response = await _apiClient.post(ApiEndpoints.users, data: model.toJson());
    final success = response.data['success'];
    return success == true || success == 'true';
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    final success = response.data['success'];
    if (success == true || success == 'true') {
      final data = (response.data['data'] as Map<String, dynamic>?) ??
          (response.data['user'] as Map<String, dynamic>?);

      if (data == null) {
        return null;
      }

      final loggedInUser = AuthApiModel.fromJson(data);

      await _userSessionService.saveUserSession(
        userId: loggedInUser.authId ?? '',
        email: loggedInUser.email,
        fullName: loggedInUser.ownerName,
        username: loggedInUser.username ?? loggedInUser.email,
        phoneNumber: loggedInUser.phoneNumber.isEmpty ? null : loggedInUser.phoneNumber,
        profilePicture: loggedInUser.profilePicture,
      );

      return loggedInUser;
    }
    return null;
  }

  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    return true;
  }

  @override
  Future<AuthApiModel?> getUserByEmail(String email) {
    return Future.value(null);
  }
}
