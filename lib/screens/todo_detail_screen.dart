import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import 'edit_todo_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  final int todoId;

  const TodoDetailScreen({Key? key, required this.todoId}) : super(key: key);

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
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
      final todo = await Provider.of<TodoProvider>(
        context,
        listen: false,
      ).fetchTodo(widget.todoId);

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
        title: const Text('Todo Details'),
        actions: [
          if (_todo != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => EditTodoScreen(todo: _todo!),
                  ),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTodo, child: const Text('Retry')),
          ],
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
          Row(
            children: [
              Expanded(
                child: Text(
                  _todo!.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Checkbox(
                value: _todo!.completed,
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<TodoProvider>(context, listen: false)
                        .toggleTodoStatus(_todo!.id, value)
                        .then((_) => _loadTodo());
                  }
                },
              ),
              Text(_todo!.completed ? 'Completed' : 'Not completed'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Description:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(_todo!.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Created at:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_formatDate(_todo!.createdAt)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Last updated:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_formatDate(_todo!.updatedAt)),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Delete Todo'),
                        content: Text(
                          'Are you sure you want to delete "${_todo!.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                );

                if (confirmed == true) {
                  final success = await Provider.of<TodoProvider>(
                    context,
                    listen: false,
                  ).deleteTodo(_todo!.id);

                  if (success && mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Todo'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
