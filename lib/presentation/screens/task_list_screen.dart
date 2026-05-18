import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/task_bloc.dart';
import '../../bloc/task_event.dart';
import '../../bloc/task_state.dart';
import '../../data/models/task_model.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_item_card.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskLoaded && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }

            if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TaskLoading;
            final isSyncing = state is TaskLoaded && state.isSyncing;
            final tasks = state is TaskLoaded ? state.tasks : <TaskModel>[];

            final activeTasks = tasks.where((task) => !task.isCompleted).toList();
            final completedTasks =
                tasks.where((task) => task.isCompleted).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskBloc>().add(const LoadTasks());
              },
              child: Stack(
                children: [
                  CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          currentDate: currentDate,
                          onAddTask: () => _openTaskSheet(context),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Tasks',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (isLoading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (tasks.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(
                            onAddTask: () => _openTaskSheet(context),
                          ),
                        )
                      else ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                          sliver: SliverList.separated(
                            itemBuilder: (context, index) {
                              final task = activeTasks[index];
                              return TaskItemCard(
                                task: task,
                                onEdit: () => _openTaskSheet(context, task: task),
                                onToggle: () {
                                  context
                                      .read<TaskBloc>()
                                      .add(ToggleTaskStatus(task));
                                },
                                onDismissed: () {
                                  context.read<TaskBloc>().add(DeleteTask(task.id));
                                },
                              );
                            },
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemCount: activeTasks.length,
                          ),
                        ),
                        if (completedTasks.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                'Completed',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        if (completedTasks.isNotEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
                            sliver: SliverList.separated(
                              itemBuilder: (context, index) {
                                final task = completedTasks[index];
                                return TaskItemCard(
                                  task: task,
                                  completed: true,
                                  onEdit: () =>
                                      _openTaskSheet(context, task: task),
                                  onToggle: () {
                                    context
                                        .read<TaskBloc>()
                                        .add(ToggleTaskStatus(task));
                                  },
                                  onDismissed: () {
                                    context.read<TaskBloc>().add(DeleteTask(task.id));
                                  },
                                );
                              },
                                separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemCount: completedTasks.length,
                            ),
                          ),
                      ],
                    ],
                  ),
                  if (isSyncing)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: true,
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.03),
                          alignment: Alignment.topCenter,
                          child: const LinearProgressIndicator(minHeight: 2),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: FloatingActionButton.extended(
          onPressed: () => _openTaskSheet(context),
          backgroundColor: const Color(0xFF5D479D),
          foregroundColor: Colors.white,
          label: const Text('Add New Task'),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openTaskSheet(BuildContext context, {TaskModel? task}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TaskFormSheet(task: task);
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.currentDate, required this.onAddTask});

  final String currentDate;
  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: const BoxDecoration(
        color: Color(0xFF5D479D),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentDate,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Text(
            'My Todo List',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Organize your tasks with a clean CRUD workflow.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onAddTask,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5D479D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add New Task'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTask});

  final VoidCallback onAddTask;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF5D479D).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt,
                size: 42,
                color: Color(0xFF5D479D),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first task.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAddTask,
              child: const Text('Create Task'),
            ),
          ],
        ),
      ),
    );
  }
}