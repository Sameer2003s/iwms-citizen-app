import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Layered import
import '../models/user_model.dart';

// ⚠️ MOCK DATA FOR SIMULATION - REPLACE WITH REAL API RESPONSES
const Map<String, dynamic> _mockUserData = {
  'user_id': '12345',
  'user_name': 'Citizen User', 
  'role': 'citizen', 
  'auth_token': 'mock_jwt_token_12345',
};

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
    // 🛑 IMPLEMENTATION POINT: REPLACE MOCK LOGIN WITH ACTUAL API CALL
    // Example of real implementation:
    // final response = await dioClient.post('/api/login', data: {'mobile': mobileNumber, 'otp': otp});
    // final user = UserModel.fromJson(response.data);
    
    // --- MOCK IMPLEMENTATION START ---
    final user = UserModel.fromJson(_mockUserData);
    // Simulate successful API call delay
    await Future.delayed(const Duration(milliseconds: 500)); 
    // --- MOCK IMPLEMENTATION END ---
    
    await _sharedPreferences.setString(_authTokenKey, user.authToken);
    return user;
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await _sharedPreferences.remove(_authTokenKey);
  }

  // --- FETCH USER ROLE (From local storage/API after token check) ---
  Future<UserModel?> getAuthenticatedUser() async {
    final token = _sharedPreferences.getString(_authTokenKey);
    
    if (token == null) {
      return null;
    }

    // 🛑 IMPLEMENTATION POINT: REPLACE MOCK USER FETCH WITH ACTUAL API CALL (or JWT verification)
    // Example of real implementation:
    // dioClient.options.headers['Authorization'] = 'Bearer $token';
    // final response = await dioClient.get('/api/user/profile');
    // return UserModel.fromJson(response.data);

    // --- MOCK IMPLEMENTATION START ---
    // Simulate successful token validation/user fetch
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel.fromJson(_mockUserData);
    // --- MOCK IMPLEMENTATION END ---
  }
}
