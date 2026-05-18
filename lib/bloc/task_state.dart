import 'package:equatable/equatable.dart';

import '../data/models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  const TaskLoaded({
    required this.tasks,
    this.isSyncing = false,
    this.message,
  });

  final List<TaskModel> tasks;
  final bool isSyncing;
  final String? message;

  @override
  List<Object?> get props => [tasks, isSyncing, message];

  TaskLoaded copyWith({
    List<TaskModel>? tasks,
    bool? isSyncing,
    String? message,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      isSyncing: isSyncing ?? this.isSyncing,
      message: message,
    );
  }
}

class TaskError extends TaskState {
  const TaskError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}