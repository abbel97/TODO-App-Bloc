import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepository {
  TaskRepository(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  Future<List<TaskModel>> getTasks() => _remoteDataSource.getTasks();

  Future<TaskModel> createTask(TaskModel task) =>
      _remoteDataSource.createTask(task);

  Future<TaskModel> updateTask(TaskModel task) =>
      _remoteDataSource.updateTask(task);

  Future<void> deleteTask(String id) => _remoteDataSource.deleteTask(id);
}