import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService _service;

  TaskBloc({TaskService? service})
      : _service = service ?? TaskService(),
        super(TaskInitial()) {
    on<LoadTasks>(_onLoad);
    on<AddTask>(_onAdd);
    on<UpdateTask>(_onUpdate);
    on<DeleteTask>(_onDelete);
    on<ToggleTask>(_onToggle);
  }

  // Returns a mutable copy of the current task list
  List<TaskModel> get _tasks =>
      state is TaskLoaded ? List.from((state as TaskLoaded).tasks) : [];

  String _errorMessage(Object e) {
    if (e is DioException) {
      return e.response?.data?.toString() ??
          e.message ??
          'Network error. Please try again.';
    }
    return 'Something went wrong.';
  }

  //Load

  Future<void> _onLoad(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _service.fetchAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(_errorMessage(e)));
    }
  }

  //Add

  Future<void> _onAdd(AddTask event, Emitter<TaskState> emit) async {
    try {
      final created = await _service.create(event.task);
      final tasks = _tasks..insert(0, created);
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(_errorMessage(e)));
    }
  }

  // Update

  Future<void> _onUpdate(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final updated = await _service.update(event.task);
      final tasks = _tasks;
      final index = tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) tasks[index] = updated;
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError(_errorMessage(e)));
    }
  }

  //Delete

  Future<void> _onDelete(DeleteTask event, Emitter<TaskState> emit) async {
    final backup = _tasks;
    emit(TaskLoaded(_tasks..removeWhere((t) => t.id == event.id)));
    try {
      await _service.delete(event.id);
    } catch (e) {
      emit(TaskLoaded(backup));
      emit(TaskError(_errorMessage(e)));
    }
  }

  Future<void> _onToggle(ToggleTask event, Emitter<TaskState> emit) async {
    final toggled = event.task.copyWith(isCompleted: !event.task.isCompleted);
    // Optimistic update
    final tasks = _tasks;
    final index = tasks.indexWhere((t) => t.id == event.task.id);
    if (index != -1) tasks[index] = toggled;
    emit(TaskLoaded(tasks));
    try {
      await _service.update(toggled);
    } catch (e) {
      // Rollback
      final rollback = _tasks;
      final ri = rollback.indexWhere((t) => t.id == event.task.id);
      if (ri != -1) rollback[ri] = event.task;
      emit(TaskLoaded(rollback));
      emit(TaskError(_errorMessage(e)));
    }
  }
}
