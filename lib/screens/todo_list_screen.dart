import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo_item.dart';
import '../state/todo_list_notifier.dart';
import '../widgets/todo_form_sheet.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: const _TodoListBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTodoSheet(BuildContext context) async {
    final Map<String, String>? result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TodoFormSheet(),
    );

    if (result != null && context.mounted) {
      await context.read<TodoListNotifier>().addTodo(
            result['title'] ?? '',
            description: result['description'] ?? '',
          );
    }
  }
}

class _TodoListBody extends StatelessWidget {
  const _TodoListBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoListNotifier>(
      builder: (BuildContext context, TodoListNotifier notifier, _) {
        if (notifier.isLoading && notifier.todos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (notifier.error != null && notifier.todos.isEmpty) {
          return Center(
            child: Text(
              notifier.error!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        if (notifier.todos.isEmpty) {
          return const _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: notifier.loadTodos,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (BuildContext context, int index) {
              final TodoItem todo = notifier.todos[index];
              return _TodoTile(todo: todo);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: notifier.todos.length,
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.todo});

  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    final TodoListNotifier notifier = context.read<TodoListNotifier>();
    return Dismissible(
      key: ValueKey<String>(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => notifier.deleteTodo(todo.id),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEditSheet(context, notifier),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => notifier.toggleTodo(todo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration:
                                  todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                      ),
                      if (todo.description.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          todo.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Created ${_formatDate(todo.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showOptionsMenu(context, notifier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditSheet(BuildContext context, TodoListNotifier notifier) async {
    final Map<String, String>? result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TodoFormSheet(
        initialTitle: todo.title,
        initialDescription: todo.description,
      ),
    );

    if (result != null && context.mounted) {
      await notifier.updateTodo(
        todo.copyWith(
          title: result['title'] ?? todo.title,
          description: result['description'] ?? todo.description,
        ),
      );
    }
  }

  Future<void> _showOptionsMenu(BuildContext context, TodoListNotifier notifier) async {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final Offset position = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    final String? action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height,
        position.dx + size.width,
        position.dy,
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
    );

    switch (action) {
      case 'edit':
        await _showEditSheet(context, notifier);
        break;
      case 'delete':
        await notifier.deleteTodo(todo.id);
        break;
      default:
        break;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
