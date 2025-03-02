import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Check if user is authenticated
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      print("Checking for existing auth token...");
      String? token = await _apiService.getToken();
      print("Token found: ${token != null}");

      _isAuthenticated = token != null;

      // If we have a token, verify it's still valid by making a request
      if (_isAuthenticated) {
        try {
          print("Validating token...");
          // You could make a simple API call here, like getting the user profile
          // await _apiService.getProfile();
          print("Token is valid");
        } catch (e) {
          print("Token validation failed: $e");
          // If the token is invalid, clear it
          await _apiService.removeToken();
          _isAuthenticated = false;
        }
      }

      return _isAuthenticated;
    } catch (e) {
      print("Error checking auth status: $e");
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password);
      _isAuthenticated = response['token'] != null;
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }
      notifyListeners();
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  // Improve the login method with better error handling
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      _isAuthenticated = response['token'] != null;
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }
      return response;
    } catch (e) {
      print('Login error: $e');
      // Handle the error appropriately
      return {'error': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
