class Todo {
  final int id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    this.dueDate,
  });

  // Create a copy of this Todo with updated properties
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  // Convert Todo instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
    };
  }

  // Create Todo instance from JSON map
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'] == 1, // Convert 1 to true, 0 to false
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }
}
