import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

class TodoController extends GetxController {
  final ApiService _apiService = ApiService();
  final todos = <Todo>[].obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  Future<void> fetchTodos() async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _apiService.getTodos();
      todos.value = response.map((item) => Todo.fromJson(item)).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTodo(
    String title,
    String? description,
    DateTime? dueDate,
  ) async {
    isLoading.value = true;
    error.value = null;

    try {
      final response = await _apiService.createTodo(
        title,
        description ?? '',
        dueDate,
      );

      final newTodo = Todo.fromJson(response);
      todos.add(newTodo);

      Get.snackbar(
        'Success',
        'Todo added successfully',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> updateTodo(
    int id, {
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
  }) async {
    isLoading.value = true;
    error.value = null;

    // Find the todo and update it locally first for immediate UI response
    final todoIndex = todos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      final updatedTodo = todos[todoIndex].copyWith(
        title: title,
        description: description,
        completed: completed,
        dueDate: dueDate,
      );
      todos[todoIndex] = updatedTodo;
    }

    try {
      final response = await _apiService.updateTodo(
        id,
        title: title,
        description: description,
        dueDate: dueDate,
        completed: completed,
      );

      final updatedTodo = Todo.fromJson(response);
      final index = todos.indexWhere((todo) => todo.id == id);

      if (index != -1) {
        todos[index] = updatedTodo;

        Get.snackbar(
          'Success',
          'Todo updated successfully',
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw 'Todo not found';
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

  Future<void> toggleTodoStatus(int id, bool completed) async {
    isLoading.value = true;
    error.value = null;

    try {
      await _apiService.updateTodo(id, completed: completed);

      final index = todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        final todo = todos[index];
        todos[index] = todo.copyWith(completed: completed);
      } else {
        throw 'Todo not found';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTodo(int id) async {
    isLoading.value = true;
    error.value = null;

    try {
      await _apiService.deleteTodo(id);
      todos.removeWhere((todo) => todo.id == id);

      Get.snackbar(
        'Success',
        'Todo deleted successfully',
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Todo? getTodoById(int id) {
    final index = todos.indexWhere((todo) => todo.id == id);
    return index != -1 ? todos[index] : null;
  }

  // Statistics getters
  int get totalTodos => todos.length;
  int get completedTodos => todos.where((todo) => todo.completed).length;
  int get pendingTodos => todos.where((todo) => !todo.completed).length;
  double get completionRate =>
      todos.isEmpty ? 0 : (completedTodos / totalTodos) * 100;
}
