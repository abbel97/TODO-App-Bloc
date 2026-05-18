import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/errors/app_exception.dart';
import '../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc(this._repository) : super(const TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
  }

  final TaskRepository _repository;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(const TaskLoading());
    try {
      final tasks = await _repository.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } on AppException catch (error) {
      emit(TaskError(error.message));
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    final loadedState = state is TaskLoaded ? state as TaskLoaded : null;
    if (loadedState != null) {
      emit(loadedState.copyWith(isSyncing: true, message: null));
    }

    try {
      await _repository.createTask(event.task);
      await _refreshTasks(emit, successMessage: 'Task added successfully');
    } on AppException catch (error) {
      emit(TaskError(error.message));
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    final loadedState = state is TaskLoaded ? state as TaskLoaded : null;
    if (loadedState != null) {
      emit(loadedState.copyWith(isSyncing: true, message: null));
    }

    try {
      await _repository.updateTask(event.task);
      await _refreshTasks(emit, successMessage: 'Task updated successfully');
    } on AppException catch (error) {
      emit(TaskError(error.message));
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    final loadedState = state is TaskLoaded ? state as TaskLoaded : null;
    if (loadedState != null) {
      emit(loadedState.copyWith(isSyncing: true, message: null));
    }

    try {
      await _repository.deleteTask(event.taskId);
      await _refreshTasks(emit, successMessage: 'Task deleted successfully');
    } on AppException catch (error) {
      emit(TaskError(error.message));
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _onToggleTaskStatus(
    ToggleTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = event.task.copyWith(isCompleted: !event.task.isCompleted);
    final loadedState = state is TaskLoaded ? state as TaskLoaded : null;
    if (loadedState != null) {
      emit(loadedState.copyWith(isSyncing: true, message: null));
    }

    try {
      await _repository.updateTask(updatedTask);
      await _refreshTasks(emit, successMessage: 'Task status updated');
    } on AppException catch (error) {
      emit(TaskError(error.message));
    } catch (error) {
      emit(TaskError(error.toString()));
    }
  }

  Future<void> _refreshTasks(
    Emitter<TaskState> emit, {
    required String successMessage,
  }) async {
    final tasks = await _repository.getTasks();
    emit(TaskLoaded(tasks: tasks, message: successMessage));
  }
}