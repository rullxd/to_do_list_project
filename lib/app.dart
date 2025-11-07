import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/todo_repository.dart';
import 'screens/todo_list_screen.dart';
import 'state/todo_list_notifier.dart';

class ToDoListApp extends StatelessWidget {
  const ToDoListApp({super.key, required this.repository});

  final TodoRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TodoListNotifier>(
      create: (_) => TodoListNotifier(repository)..loadTodos(),
      child: MaterialApp(
        title: 'Supabase Todo List',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const TodoListScreen(),
      ),
    );
  }
}
