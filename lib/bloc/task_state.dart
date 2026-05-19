import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

// Initial state before anything loads
class TaskInitial extends TaskState {}

// Shown during any network call
class TaskLoading extends TaskState {}

// Holds the full task list — single source of truth
class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  const TaskLoaded(this.tasks);

  List<TaskModel> get active    => tasks.where((t) => !t.isCompleted).toList();
  List<TaskModel> get completed => tasks.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [tasks];
}

// Shown when an API call fails
class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}