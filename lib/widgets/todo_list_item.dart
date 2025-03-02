import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../theme/app_theme.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final Function(bool) onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TodoListItem({
    Key? key,
    required this.todo,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              // Checkbox with animated state
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Checkbox(
                  value: todo.completed,
                  onChanged: (value) {
                    if (value != null) {
                      onToggle(value);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Todo content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration:
                              todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              todo.completed
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                        ),
                      ),
                      if (todo.description != null &&
                          todo.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              decoration:
                                  todo.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                        ),
                      if (todo.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(todo.dueDate!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorColor,
                ),
                onPressed: onDelete,
                splashRadius: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
