import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final isAuthenticated = false.obs;
  final isLoading = false.obs;
  final user = Rxn<User>();
  final error = Rxn<String>();

  final obscurePassword = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Check for existing token
    checkAuthStatus();
  }

  Future<bool> checkAuthStatus() async {
    isLoading.value = true;
    error.value = null;

    try {
      // Check if token exists
      final token = await _apiService.getToken();

      if (token != null) {
        // You can add API call to validate token here if needed
        // For example, fetch user profile

        // For now, just set authenticated to true if token exists
        isAuthenticated.value = true;
        return true;
      } else {
        isAuthenticated.value = false;
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      isAuthenticated.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _apiService.login(email, password);

      if (response['user'] != null) {
        user.value = User.fromJson(response['user']);
      }

      isAuthenticated.value = response['token'] != null;
      return response;
    } catch (e) {
      error.value = e.toString();
      return {'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _apiService.register(name, email, password);

      if (response['user'] != null) {
        user.value = User.fromJson(response['user']);
      }

      isAuthenticated.value = response['token'] != null;
      return response;
    } catch (e) {
      error.value = e.toString();
      return {'message': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _apiService.logout();
      user.value = null;
      isAuthenticated.value = false;
    } catch (e) {
      error.value = e.toString();
      // Still clear user and authenticated state even if API fails
      user.value = null;
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile(String name, String email) async {
    isLoading.value = true;
    error.value = null;

    try {
      // Implement API call for profile update
      // For now, just update the local user
      if (user.value != null) {
        user.value = user.value!.copyWith(name: name, email: email);

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
