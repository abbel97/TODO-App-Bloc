import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/task_bloc.dart';
import '../../bloc/task_event.dart';
import '../../bloc/task_state.dart';
import '../../models/task_model.dart';
import 'task_form_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _purple     = Color(0xFF6B35B5);
  static const _purpleDeep = Color(0xFF4A2080);
  static const _bgColor    = Color(0xFFF4F3FA);

  void _openSheet(BuildContext context, {TaskModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: TaskFormSheet(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _Header(),

          Expanded(
            child: BlocConsumer<TaskBloc, TaskState>(
              listener: (context, state) {
                if (state is TaskError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: _purple),
                  );
                }

                if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<TaskBloc>().add(LoadTasks()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TaskLoaded) {
                  return RefreshIndicator(
                    color: _purple,
                    onRefresh: () async =>
                        context.read<TaskBloc>().add(LoadTasks()),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                      children: [
                        if (state.active.isEmpty)
                          _EmptyState()
                        else
                          ...state.active.map(
                            (task) => _TaskTile(
                              task: task,
                              onEdit: () =>
                                  _openSheet(context, existing: task),
                              onToggle: () =>
                                  context.read<TaskBloc>().add(ToggleTask(task)),
                              onDelete: () =>
                                  context.read<TaskBloc>().add(DeleteTask(task.id!)),
                            ),
                          ),

                        // completed tasks
                        if (state.completed.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...state.completed.map(
                            (task) => _TaskTile(
                              task: task,
                              onEdit: () =>
                                  _openSheet(context, existing: task),
                              onToggle: () =>
                                  context.read<TaskBloc>().add(ToggleTask(task)),
                              onDelete: () =>
                                  context.read<TaskBloc>().add(DeleteTask(task.id!)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),

      // ─Add new task button 
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purpleDeep,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add New Task',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// header with date and title
class _Header extends StatelessWidget {
  static const _purple     = Color(0xFF6B35B5);
  static const _purpleDeep = Color(0xFF4A2080);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('MMMM d, yyyy').format(now);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 28,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_purpleDeep, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dateStr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'My Todo List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

//delete (swipe right) 
class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  static const _purple = Color(0xFF6B35B5);

  String get _formattedDate {
    final date = DateTime.tryParse(task.dueDate);
    if (date == null) return task.dueDate;
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.startToEnd, // swipe right only
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: const Text('Delete task.'),
            content: Text('Delete "${task.title}"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: task.isCompleted
                  ? Colors.grey
                  : const Color(0xFF1F1F1F),
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.grey,
            ),
          ),
          subtitle: task.dueDate.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    _formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isCompleted
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit icon — only for active tasks
              if (!task.isCompleted)
                GestureDetector(
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.edit_outlined,
                        color: Colors.grey.shade400, size: 20),
                  ),
                ),
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? _purple : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? _purple
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline,
              color: Color(0xFFD1C4E9), size: 56),
          SizedBox(height: 12),
          Text(
            'No tasks yet.\nTap "Add New Task" to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}