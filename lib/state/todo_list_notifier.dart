import 'package:flutter/foundation.dart';

import '../models/todo_item.dart';
import '../repositories/todo_repository.dart';

class TodoListNotifier extends ChangeNotifier {
  TodoListNotifier(this._repository);

  final TodoRepository _repository;

  List<TodoItem> _todos = <TodoItem>[];
  bool _isLoading = false;
  String? _error;

  List<TodoItem> get todos => _todos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodos() async {
    _setLoading(true);
    try {
      _todos = await _repository.fetchTodos();
      _error = null;
    } catch (error, stackTrace) {
      debugPrint('Failed to load todos: $error');
      debugPrint('$stackTrace');
      _error = 'Unable to load tasks';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addTodo(String title, {String description = ''}) async {
    _setLoading(true);
    try {
      final TodoItem todo = await _repository.createTodo(title: title, description: description);
      _todos = <TodoItem>[todo, ..._todos];
      _error = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to add todo: $error');
      debugPrint('$stackTrace');
      _error = 'Unable to add task';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTodo(TodoItem todo) async {
    await updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
  }

  Future<void> updateTodo(TodoItem todo) async {
    _setLoading(true);
    try {
      final TodoItem updated = await _repository.updateTodo(todo);
      _todos = _todos.map((TodoItem item) => item.id == updated.id ? updated : item).toList();
      _error = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to update todo: $error');
      debugPrint('$stackTrace');
      _error = 'Unable to update task';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTodo(String id) async {
    _setLoading(true);
    try {
      await _repository.deleteTodo(id);
      _todos = _todos.where((TodoItem item) => item.id != id).toList();
      _error = null;
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('Failed to delete todo: $error');
      debugPrint('$stackTrace');
      _error = 'Unable to delete task';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
