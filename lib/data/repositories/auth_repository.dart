// lib/data/repositories/auth_repository.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/api_config.dart'; // Assuming this exists
import '../../core/di.dart'; // Import getIt to access Dio

class AuthRepository {
  final SharedPreferences _prefs;
  final Dio _dio;

  final Completer<void> _initCompleter = Completer();

  AuthRepository({required SharedPreferences prefs, required Dio dio})
      : _prefs = prefs,
        _dio = dio {
    _initCompleter.complete(); 
  }

  Future<void> initialize() => _initCompleter.future;

  Future<UserModel?> getAuthenticatedUser() async {
    final authToken = _prefs.getString('authToken');
    final role = _prefs.getString('authRole');
    final userName = _prefs.getString('authUserName');
    final userId = _prefs.getString('authUserId'); 

    if (authToken != null && role != null && userName != null && userId != null) {
      return UserModel(
        userId: userId,
        userName: userName,
        role: role,
        authToken: authToken,
      );
    }
    return null;
  }

  // --- CITIZEN MOCK LOGIN ---
  Future<UserModel> login(
      {required String mobileNumber, required String otp}) async {
    final user = UserModel(
      userId: 'mock-citizen-id-123',
      userName: 'Citizen User',
      role: 'citizen',
      authToken: 'mock-citizen-token-123',
    );

    await _prefs.setString('authToken', user.authToken);
    await _prefs.setString('authRole', user.role);
    await _prefs.setString('authUserName', user.userName);
    await _prefs.setString('authUserId', user.userId);
    
    return user;
  }

  // --- REAL DRIVER LOGIN ---
  Future<UserModel> loginDriver(
      {required String userName, required String password}) async {
    try {
      final response = await _dio.post(
        'http://zigma.in:80/d2d_app/login.php', 
        data: {
          'action': 'login',
          'user_name': userName,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      Map<String, dynamic> result;
      if (response.data is String) {
        result = json.decode(response.data) as Map<String, dynamic>;
      } else {
        result = response.data as Map<String, dynamic>;
      }

      if (result['status'] == 1 && result['msg'] == "success_login") {
        final staffName = result['data']?['staff'] ?? 'Driver';
        final staffId = result['data']?['staffid'] ?? 'driver-id';
        
        final user = UserModel(
          userId: staffId,
          userName: staffName,
          role: 'driver',
          authToken: staffId, // Use staffId as the "token"
        );

        // Save to SharedPreferences
        await _prefs.setString('authToken', user.authToken);
        await _prefs.setString('authRole', user.role);
        await _prefs.setString('authUserName', user.userName);
        await _prefs.setString('authUserId', user.userId);

        return user;
      } else {
        throw Exception(result['error'] ?? 'Invalid driver login');
      }
    } catch (e) {
      throw Exception('Failed to log in as driver: $e');
    }
  }
  // --- END DRIVER LOGIN ---

  Future<void> logout() async {
    await _prefs.remove('authToken');
    await _prefs.remove('authRole');
    await _prefs.remove('authUserName');
    await _prefs.remove('authUserId');
  }
}