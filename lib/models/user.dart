class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  // Create a copy with updated values
  User copyWith({int? id, String? name, String? email}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  // Create User from JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], email: json['email']);
  }

  // Convert User to JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
