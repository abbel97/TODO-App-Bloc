import 'package:equatable/equatable.dart';

import '../data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}

class AddTask extends TaskEvent {
  const AddTask(this.task);

  final TaskModel task;

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  const UpdateTask(this.task);

  final TaskModel task;

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  const DeleteTask(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskStatus extends TaskEvent {
  const ToggleTaskStatus(this.task);

  final TaskModel task;

  @override
  List<Object?> get props => [task];
}