import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/screens/user_screen.dart';
import 'package:todo_app/widgets/todo_list_item.dart';
import '../controllers/auth_controller.dart';
import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import 'add_todo_screen.dart';
import 'todo_detail_screen.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TodoController todoController = Get.find<TodoController>();
  final AuthController authController = Get.find<AuthController>();
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Extract the loading logic to a separate method
  Future<void> _loadTodos() async {
    await todoController.fetchTodos();
  }

  Future<void> _logout() async {
    await authController.logout();
    Get.offAll(() => LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildTodoScreen() : const UsersScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
        ],
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () => Get.to(() => const AddTodoScreen()),
                child: const Icon(Icons.add),
                backgroundColor: AppTheme.primaryColor,
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTodoScreen() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            title: const Text('My Tasks'),
            pinned: true,
            floating: true,
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Active'), Tab(text: 'Completed')],
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryColor,
            ),
          ),
        ];
      },
      body: Obx(() {
        if (todoController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (todoController.error.value != null) {
          return _buildErrorWidget();
        }

        // Filter todos based on completion status
        final activeTodos =
            todoController.todos.where((todo) => !todo.completed).toList();
        final completedTodos =
            todoController.todos.where((todo) => todo.completed).toList();

        return TabBarView(
          controller: _tabController,
          children: [
            // Active todos tab
            _buildTodoList(activeTodos),

            // Completed todos tab
            _buildTodoList(completedTodos),
          ],
        );
      }),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppTheme.errorColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${todoController.error.value}',
                style: const TextStyle(color: AppTheme.errorColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTodos,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 0
                  ? 'No active tasks'
                  : 'No completed tasks',
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_tabController.index == 0)
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const AddTodoScreen()),
                icon: const Icon(Icons.add),
                label: const Text('Add New Task'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TodoListItem(
              todo: todo,
              onToggle: (completed) {
                todoController.updateTodo(
                  todo.id,
                  title: todo.title,
                  description: todo.description,
                  completed: completed,
                  dueDate: todo.dueDate,
                );
              },
              onTap: () {
                Get.to(() => TodoDetailScreen(todoId: todo.id));
              },
              onDelete: () async {
                final confirmed = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Delete Task'),
                    content: Text(
                      'Are you sure you want to delete "${todo.title}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  todoController.deleteTodo(todo.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
