import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static const String baseUrl = "http://localhost:5047"; 
  static final Dio _dio = Dio();

  // SIGN UP
  static Future<bool> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _dio.post('$baseUrl/users/register', data: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      });
      return response.statusCode == 201;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  // LOGIN
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('$baseUrl/users/login', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['userId'];
        
        // Use your existing storage logic
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: 'user_id', value: userId.toString());
        await _storage.write(key: 'first_name', value: response.data['firstName']);
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  static Future<void> logout() async => await _storage.deleteAll();
  
  static Future<String?> getToken() async => await _storage.read(key: _tokenKey);
}