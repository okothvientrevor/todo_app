class Todo {
  final int id;
  final String title;
  final String description;
  bool completed;
  final String createdAt;
  final String updatedAt;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] == 1, // Convert 1 to true, 0 to false
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0, // Convert bool back to 1 or 0
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
