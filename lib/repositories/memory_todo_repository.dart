import 'dart:math';

import '../models/todo_item.dart';
import 'todo_repository.dart';

class MemoryTodoRepository implements TodoRepository {
  final List<TodoItem> _todos = <TodoItem>[];
  final Random _random = Random();

  @override
  Future<TodoItem> createTodo({required String title, String description = ''}) async {
    final TodoItem todo = TodoItem(
      id: _generateId(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _todos.insert(0, todo);
    return todo;
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((TodoItem todo) => todo.id == id);
  }

  @override
  Future<List<TodoItem>> fetchTodos() async {
    _todos.sort((TodoItem a, TodoItem b) => b.createdAt.compareTo(a.createdAt));
    return List<TodoItem>.unmodifiable(_todos);
  }

  @override
  Future<TodoItem> updateTodo(TodoItem todo) async {
    final int index = _todos.indexWhere((TodoItem element) => element.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
    return todo;
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(999999).toString().padLeft(6, '0');
  }
}
