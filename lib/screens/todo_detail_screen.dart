import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_app/screens/home_screen.dart';
import '../controllers/todo_controller.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';
import 'edit_todo_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  final int todoId;
  const TodoDetailScreen({Key? key, required this.todoId}) : super(key: key);
  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  final TodoController todoController = Get.find<TodoController>();
  bool _isLoading = true;
  Todo? _todo;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTodo();
  }

  Future<void> _loadTodo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Use the getTodoById method from your TodoController
      final todo = todoController.getTodoById(widget.todoId);
      setState(() {
        _todo = todo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Task Details'),

        actions: [
          if (_todo != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Get.to(
                  () => EditTodoScreen(todo: _todo!),
                );
                if (updated == true) {
                  _loadTodo();
                }
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    if (_error != null) {
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
                  'Error: $_error',
                  style: const TextStyle(color: AppTheme.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadTodo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_todo == null) {
      return const Center(child: Text('Todo not found'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            color:
                _todo!.completed
                    ? AppTheme.successColor.withOpacity(0.2)
                    : AppTheme.cardColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color:
                    _todo!.completed
                        ? AppTheme.successColor
                        : Colors.transparent,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                _todo!.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color:
                    _todo!.completed
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                size: 28,
              ),
              title: Text(
                _todo!.completed ? 'Completed' : 'In Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      _todo!.completed
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                ),
              ),
              trailing: Switch(
                value: _todo!.completed,
                activeColor: AppTheme.successColor,
                onChanged: (value) {
                  setState(() {
                    _todo = _todo!.copyWith(completed: value);
                  });
                  todoController.updateTodo(
                    _todo!.id,
                    title: _todo!.title,
                    description: _todo!.description,
                    completed: _todo!.completed,
                    dueDate: _todo!.dueDate,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title section
          Text(
            'Title',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _todo!.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Description section
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _todo!.description?.isEmpty ?? true
                ? 'No description provided'
                : _todo!.description ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  _todo!.description?.isEmpty ?? true
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // Due date section
          if (_todo!.dueDate != null) ...[
            Text(
              'Due Date',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color:
                      _isOverdue(_todo!.dueDate)
                          ? AppTheme.errorColor
                          : AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_todo!.dueDate!),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        _isOverdue(_todo!.dueDate)
                            ? AppTheme.errorColor
                            : AppTheme.textPrimary,
                    fontWeight:
                        _isOverdue(_todo!.dueDate)
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
                if (_isOverdue(_todo!.dueDate) && !_todo!.completed) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.errorColor),
                    ),
                    child: Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],

          Center(
            child: OutlinedButton.icon(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorColor,
              ),
              label: const Text('Delete Task'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                _showDeleteConfirmation();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isOverdue(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return AppTheme.errorColor;
      case 2:
        return Colors.orange;
      case 1:
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 3:
        return 'High';
      case 2:
        return 'Medium';
      case 1:
        return 'Low';
      default:
        return 'None';
    }
  }

  void _showDeleteConfirmation() {
    Get.defaultDialog(
      title: 'Delete Task',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: const Text(
        'Are you sure you want to delete this task? This action cannot be undone.',
        textAlign: TextAlign.center,
      ),
      confirm: ElevatedButton(
        onPressed: () {
          todoController.deleteTodo(_todo!.id);
          Get.back();
          Get.back();
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
        child: const Text('Delete'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
