// lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iwms_citizen_app/core/api_config.dart'; // <-- FIX: Added import
import 'package:iwms_citizen_app/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _userKey = 'authenticated_user';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';

  // --- FIX: Use positional constructor ---
  AuthRepository(this._dio, this._prefs);
  // --- END FIX ---

  Future<void> initialize() async {
    // This can be used for any async setup
  }

  // --- MOCK LOGIN FOR CITIZEN ---
  Future<UserModel> login(
      {required String mobileNumber, required String otp}) async {
    // 1. Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // 2. Create a mock user
    final user = UserModel(
      userId: 'mock_citizen_123',
      userName: 'Mock Citizen',
      role: 'citizen',
      authToken: 'mock_token_for_citizen', // Now valid
    );

    // 3. Save the mock user to shared preferences
    await _prefs.setString(_userKey, user.userId);
    await _prefs.setString(_roleKey, user.role);
    await _prefs.setString(_nameKey, user.userName);

    // 4. Return the mock user
    return user;
  }
  // --- END MOCK LOGIN ---

  // --- REAL LOGIN FOR DRIVER ---
  Future<UserModel> loginDriver(
      {required String userName, required String password}) async {
    try {
      final response = await _dio.post(
        ApiConfig.driverLogin, // <-- Uses imported config
        data: {
          'action': 'login',
          'user_name': userName,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final userData = response.data['data'];
        final user = UserModel(
          userId: userData['user_id'],
          userName: userData['user_name'],
          role: 'driver', // Manually assign role
          authToken: 'driver_token_12345', // <-- FIX: Added mock token
        );

        // Save user info
        await _prefs.setString(_userKey, user.userId);
        await _prefs.setString(_roleKey, user.role);
        await _prefs.setString(_nameKey, user.userName);

        return user;
      } else {
        throw Exception(response.data['msg'] ?? 'Driver login failed');
      }
    } catch (e) {
      throw Exception('Login failed. Please check your credentials.');
    }
  }

  Future<UserModel?> getAuthenticatedUser() async {
    final userId = _prefs.getString(_userKey);
    final role = _prefs.getString(_roleKey);
    final userName = _prefs.getString(_nameKey);

    if (userId != null && role != null && userName != null) {
      return UserModel(
        userId: userId,
        userName: userName,
        role: role,
        authToken: 'restored_mock_token', // <-- FIX: Added mock token
      );
    }
    return null;
  }

  Future<void> logout() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_roleKey);
    await _prefs.remove(_nameKey);
  }
}