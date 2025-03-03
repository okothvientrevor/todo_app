import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your API base URL
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // Token storage key
  static const String _tokenKey = 'auth_token';

  // Headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Remove token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']);
        return data;
      } else {
        throw data['message'] ?? 'Login failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['token'] != null) {
        await saveToken(data['token']);
        return data;
      } else {
        throw data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final headers = await _getHeaders();
      await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
      await removeToken();
    } catch (e) {
      await removeToken(); // Still remove token even if API call fails
      throw e.toString();
    }
  }

  // Get todos
  Future<List<dynamic>> getTodos() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Failed to fetch todos';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Get single todo
  Future<dynamic> getTodo(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Todo not found';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Create todo
  Future<dynamic> createTodo(
    String title,
    String description,
    DateTime? dueDate,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'due_date': dueDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Failed to create todo';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Update todo
  Future<dynamic> updateTodo(
    int id, {
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final Map<String, dynamic> body = {};

      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (completed != null) body['completed'] = completed;
      if (dueDate != null) body['due_date'] = dueDate.toIso8601String();

      final response = await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Failed to update todo';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete todo
  Future<void> deleteTodo(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Failed to delete todo';
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
