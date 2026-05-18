import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/task_model.dart';

class TaskItemCard extends StatelessWidget {
  const TaskItemCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onToggle,
    required this.onDismissed,
    this.completed = false,
  });

  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDismissed;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDismissed();
        return false;
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFD7CDEF)
                      : const Color(0xFFE4EEF8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  completed ? Icons.event_available : Icons.notes,
                  color: const Color(0xFF5D479D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: completed ? Colors.grey : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description.isEmpty
                          ? 'No description provided'
                          : task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: completed ? Colors.grey : Colors.black54,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDueDate(task.dueDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: completed ? Colors.grey : const Color(0xFF5D479D),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: const Color(0xFF5D479D),
              ),
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF5D479D),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDueDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateFormat('MMM d, yyyy').format(parsed);
    }
    return value;
  }
}