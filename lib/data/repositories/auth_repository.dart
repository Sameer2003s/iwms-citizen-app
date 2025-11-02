// lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iwms_citizen_app/core/api_config.dart';
import 'package:iwms_citizen_app/data/models/user_model.dart';

class AuthRepository {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _userKey = 'authenticated_user';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';

  AuthRepository(this._dio, this._prefs);

  Future<void> initialize() async {
    // This can be used for any async setup
  }

  // --- MOCK LOGIN FOR CITIZEN ---
  Future<UserModel> login(
      {required String mobileNumber, required String otp}) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = UserModel(
      userId: 'mock_citizen_123',
      userName: 'Mock Citizen',
      role: 'citizen',
      authToken: 'mock_token_for_citizen',
    );
    await _prefs.setString(_userKey, user.userId);
    await _prefs.setString(_roleKey, user.role);
    await _prefs.setString(_nameKey, user.userName);
    return user;
  }

  // --- REAL LOGIN FOR DRIVER ---
  Future<UserModel> loginDriver(
      {required String userName, required String password}) async {
    try {
      final response = await _dio.post(
        ApiConfig.driverLogin,
        data: {
          'action': 'login',
          'user_name': userName,
          'password': password,
        },
        // --- THIS IS THE FIX (from d2d_waste_collection) ---
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
        // --- END FIX ---
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final userData = response.data['data'];
        final user = UserModel(
          userId: userData['user_id'],
          userName: userData['user_name'],
          role: 'driver',
          authToken: 'driver_token_${userData['user_id']}',
        );

        await _prefs.setString(_userKey, user.userId);
        await _prefs.setString(_roleKey, user.role);
        await _prefs.setString(_nameKey, user.userName);

        return user;
      } else {
        // Show the server's error message
        throw Exception(response.data['error'] ?? 'Invalid credentials');
      }
    } catch (e) {
      // This will catch the error above or Dio errors
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
        authToken: 'restored_mock_token',
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