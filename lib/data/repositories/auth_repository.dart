import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Layered import
import '../models/user_model.dart';

class AuthRepository {
  final Dio dioClient;
  final Future<SharedPreferences> sharedPreferencesFuture; 
  late SharedPreferences _sharedPreferences; 

  AuthRepository({
    required this.dioClient,
    required this.sharedPreferencesFuture, 
  });

  // --- INITIALIZATION METHOD: Resolves the Future and is called by the Bloc ---
  Future<void> initialize() async {
    // This is where the Future is finally resolved to the concrete object
    _sharedPreferences = await sharedPreferencesFuture;
  }
  // -------------------------------------------------------------------------
  
  static const String _authTokenKey = 'auth_token';

  // --- AUTHENTICATION (Login) ---
  Future<UserModel> login({
    required String mobileNumber,
    required String otp,
  }) async {
    // Note: Removed artificial Future.delayed calls for performance
    
    final mockResponse = {
      'user_id': '12345',
      'user_name': 'Citizen User', 
      'role': 'citizen', 
      'auth_token': 'mock_jwt_token_12345',
    };
    
    final user = UserModel.fromJson(mockResponse);
    await _sharedPreferences.setString(_authTokenKey, user.authToken);
    return user;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _sharedPreferences.remove(_authTokenKey);
  }

  // --- FETCH USER ROLE (From API after token check) ---
  Future<UserModel?> getAuthenticatedUser() async {
    final token = _sharedPreferences.getString(_authTokenKey);
    
    if (token == null) {
      return null;
    }

    // NOTE: Removed artificial Future.delayed calls for performance
    
    return const UserModel(
      userId: '12345',
      userName: 'Citizen User', 
      role: 'citizen', 
      authToken: 'mock_jwt_token_12345',
    );
  }
}
