import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;
  final _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserUsername = 'user_username';
  static const String _keyUserPhoneNumber = 'user_phone_number';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserRole = 'user_role';
  static const String _keyRestaurantId = 'restaurant_id';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String username,
    required String role,
    String? restaurantId,
    String? phoneNumber,
    String? profilePicture,
    String? token,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserUsername, username);
    await _prefs.setString(_keyUserRole, role);
    if (restaurantId != null) {
      await _prefs.setString(_keyRestaurantId, restaurantId);
    }
    if (phoneNumber != null) {
      await _prefs.setString(_keyUserPhoneNumber, phoneNumber);
    }
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
    if (token != null) {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  // Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserPhoneNumber);
  }


  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  // Get current user role
  String? getCurrentUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  // Get current restaurant ID
  String? getCurrentRestaurantId() {
    return _prefs.getString(_keyRestaurantId);
  }

  // Get authentication token from secure storage
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserPhoneNumber);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyRestaurantId);
    await _secureStorage.delete(key: _tokenKey);
  }
}
