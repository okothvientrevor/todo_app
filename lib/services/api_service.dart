import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final storage = FlutterSecureStorage();

  // Get token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // Set token in secure storage
  Future<void> setToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // Remove token from secure storage (logout)
  Future<void> removeToken() async {
    await storage.delete(key: 'auth_token');
  }

  // Headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await setToken(data['token']);
    }

    return data;
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['token'] != null) {
      await setToken(data['token']);
    }

    return data;
  }

  // Logout user
  Future<void> logout() async {
    final headers = await _getHeaders();
    await http.post(Uri.parse('$baseUrl/logout'), headers: headers);
    await removeToken();
  }

  // Get all todos
  Future<List<dynamic>> getTodos() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Get a single todo
  Future<Map<String, dynamic>> getTodo(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load todo');
    }
  }

  // Create a new todo
  Future<Map<String, dynamic>> createTodo(
    String title,
    String description,
  ) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: headers,
      body: jsonEncode({
        'title': title,
        'description': description,
        'completed': false,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create todo');
    }
  }

  // Update a todo
  Future<Map<String, dynamic>> updateTodo(
    int id, {
    String? title,
    String? description,
    bool? completed,
  }) async {
    final headers = await _getHeaders();
    final Map<String, dynamic> data = {};

    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (completed != null) data['completed'] = completed;

    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete todo');
    }
  }

  // Get recent users
  Future<List<dynamic>> getRecentUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/recent-users'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recent users');
    }
  }
}
