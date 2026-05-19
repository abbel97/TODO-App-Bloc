import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/task_model.dart';

class TaskService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ── READ ──────────────────────────────────────────────────────────────────

  Future<List<TaskModel>> fetchAll() async {
    final response = await _dio.get('/tasks');
    final List data = response.data as List;
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  // ── CREATE ────────────────────────────────────────────────────────────────

  Future<TaskModel> create(TaskModel task) async {
    final response = await _dio.post('/tasks', data: task.toJson());
    return TaskModel.fromJson(response.data);
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────

  Future<TaskModel> update(TaskModel task) async {
    final response = await _dio.put('/tasks/${task.id}', data: task.toJson());
    return TaskModel.fromJson(response.data);
  }

  // ── DELETE ────────────────────────────────────────────────────────────────

  Future<void> delete(String id) async {
    await _dio.delete('/tasks/$id');
  }
}