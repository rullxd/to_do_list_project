import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/todo_item.dart';
import 'todo_repository.dart';

class SupabaseTodoRepository implements TodoRepository {
  SupabaseTodoRepository(this.client);

  final SupabaseClient client;

  PostgrestTable<Map<String, dynamic>> get _table => client.from('todos');

  @override
  Future<TodoItem> createTodo({required String title, String description = ''}) async {
    final Map<String, dynamic> response = await _table
        .insert({
          'title': title,
          'description': description,
        })
        .select()
        .single();
    return TodoItem.fromMap(response);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _table.delete().eq('id', id);
  }

  @override
  Future<List<TodoItem>> fetchTodos() async {
    final List<dynamic> response = await _table.select().order('created_at', ascending: false);
    return response.map((dynamic item) => TodoItem.fromMap(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<TodoItem> updateTodo(TodoItem todo) async {
    final Map<String, dynamic> response = await _table
        .update({
          'title': todo.title,
          'description': todo.description,
          'is_complete': todo.isCompleted,
        })
        .eq('id', todo.id)
        .select()
        .single();
    return TodoItem.fromMap(response);
  }
}
