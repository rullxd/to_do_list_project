import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'repositories/todo_repository.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final TodoRepository repository = await AppBootstrapper().createRepository();
  runApp(ToDoListApp(repository: repository));
}
