import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;

  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all todos
  Future<void> fetchTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getTodos();
      _todos = response.map((todo) => Todo.fromJson(todo)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get a single todo
  Future<Todo?> fetchTodo(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getTodo(id);
      final todo = Todo.fromJson(response);
      return todo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new todo
  Future<Todo?> createTodo(String title, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createTodo(title, description);
      final newTodo = Todo.fromJson(response);
      _todos.add(newTodo);
      notifyListeners();
      return newTodo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a todo
  Future<bool> updateTodo(
    int id, {
    String? title,
    String? description,
    bool? completed,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updateTodo(
        id,
        title: title,
        description: description,
        completed: completed,
      );

      final updatedTodo = Todo.fromJson(response);
      final index = _todos.indexWhere((todo) => todo.id == id);

      if (index != -1) {
        _todos[index] = updatedTodo;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle todo completion status
  Future<bool> toggleTodoStatus(int id, bool completed) async {
    return await updateTodo(id, completed: completed);
  }

  // Delete a todo
  Future<bool> deleteTodo(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
