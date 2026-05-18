import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
  });

  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final String dueDate;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    String? dueDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: _stringValue(json, const ['id', '_id', 'taskId']) ?? '',
      title: _stringValue(json, const ['title', 'name', 'taskTitle']) ?? '',
      description:
          _stringValue(json, const ['description', 'notes', 'details']) ?? '',
      isCompleted: _boolValue(json, const [
        'isCompleted',
        'completed',
        'is_done',
        'done',
      ]),
      dueDate:
          _stringValue(json, const ['dueDate', 'due_date', 'deadline']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate,
    };
  }

  @override
  List<Object?> get props => [id, title, description, isCompleted, dueDate];

  static String? _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }

  static bool _boolValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
    }
    return false;
  }
}