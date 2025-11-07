class TodoItem {
  TodoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'].toString(),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isCompleted: map['is_complete'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_complete': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
