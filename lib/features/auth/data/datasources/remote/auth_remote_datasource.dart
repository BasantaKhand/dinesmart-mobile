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
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final success = response.data['success'];
    if (success == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String?;
      
      // Add token to userData so it's included in AuthApiModel
      userData['token'] = token;
      final loggedInUser = AuthApiModel.fromJson(userData);

      await _userSessionService.saveUserSession(
        userId: loggedInUser.authId ?? '',
        email: loggedInUser.email,
        fullName: loggedInUser.ownerName,
        username: loggedInUser.username ?? loggedInUser.email,
        role: loggedInUser.role ?? 'USER',
        restaurantId: loggedInUser.restaurantId,
        phoneNumber: loggedInUser.phoneNumber,
        profilePicture: loggedInUser.profilePicture,
        token: token,
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

  @override
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return response.data['success'] == true;
  }

  @override
  Future<AuthApiModel?> updateProfile({String? ownerName, String? phoneNumber, String? profilePicture}) async {
    final response = await _apiClient.put(
      ApiEndpoints.updateProfile,
      data: {
        if (ownerName != null) 'name': ownerName,
        if (phoneNumber != null) 'phone': phoneNumber,
        if (profilePicture != null) 'profilePicture': profilePicture,
      },
    );

    if (response.data['success'] == true) {
      final userData = response.data['data'] as Map<String, dynamic>;
      final updatedUser = AuthApiModel.fromJson(userData);
      
      // Update local session
      await _userSessionService.saveUserSession(
        userId: updatedUser.authId ?? '',
        email: updatedUser.email,
        fullName: updatedUser.ownerName,
        username: updatedUser.username ?? updatedUser.email,
        role: updatedUser.role ?? 'USER',
        restaurantId: updatedUser.restaurantId,
        phoneNumber: updatedUser.phoneNumber,
        profilePicture: updatedUser.profilePicture,
      );
      
      return updatedUser;
    }
    return null;
  }
}
