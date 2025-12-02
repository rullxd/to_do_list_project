import '../models/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> fetchTodos();

  Future<TodoItem> createTodo({
    required String title,
    String description,
  });

  Future<TodoItem> updateTodo(TodoItem todo);

  Future<void> deleteTodo(String id);
}
