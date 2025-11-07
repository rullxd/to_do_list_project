import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'repositories/memory_todo_repository.dart';
import 'repositories/supabase_todo_repository.dart';
import 'repositories/todo_repository.dart';

class AppBootstrapper {
  Future<TodoRepository> createRepository() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Supabase credentials missing. Falling back to in-memory repository.');
      return MemoryTodoRepository();
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      return SupabaseTodoRepository(Supabase.instance.client);
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize Supabase: $error');
      debugPrint('$stackTrace');
      return MemoryTodoRepository();
    }
  }
}
