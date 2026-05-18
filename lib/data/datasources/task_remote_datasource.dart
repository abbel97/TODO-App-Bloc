import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await _dio.get(ApiConstants.tasksPath);
      final data = response.data;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item))).toList();
      }

      if (data is Map<String, dynamic>) {
        final items = data['data'];
        if (items is List) {
          return items
              .whereType<Map>()
              .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }

      throw const AppException('Unexpected task response format.');
    } on DioException catch (error) {
      throw AppException(_messageFromDio(error));
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post(
        ApiConstants.tasksPath,
        data: task.toJson(),
      );
      return _parseTask(response.data, fallback: task);
    } on DioException catch (error) {
      throw AppException(_messageFromDio(error));
    }
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.tasksPath}/${task.id}',
        data: task.toJson(),
      );
      return _parseTask(response.data, fallback: task);
    } on DioException catch (error) {
      throw AppException(_messageFromDio(error));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('${ApiConstants.tasksPath}/$id');
    } on DioException catch (error) {
      throw AppException(_messageFromDio(error));
    }
  }

  TaskModel _parseTask(dynamic data, {required TaskModel fallback}) {
    if (data is Map<String, dynamic>) {
      final candidate = data['data'];
      if (candidate is Map<String, dynamic>) {
        return TaskModel.fromJson(candidate);
      }
      return TaskModel.fromJson(data);
    }

    return fallback;
  }

  String _messageFromDio(DioException error) {
    final responseMessage = error.response?.data;
    if (responseMessage is Map<String, dynamic>) {
      final message = responseMessage['message'] ?? responseMessage['error'];
      if (message != null) {
        return message.toString();
      }
    }

    return error.message ?? 'Network request failed.';
  }
}