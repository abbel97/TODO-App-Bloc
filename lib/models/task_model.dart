class TaskModel {
  final String? id;
  final String title;
  final String notes;
  final String dueDate;       // stored as 'yyyy-MM-dd'
  final bool isCompleted;

  const TaskModel({
    this.id,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.isCompleted,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id']?.toString(),
        title: json['title'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        dueDate: json['dueDate'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'notes': notes,
        'dueDate': dueDate,
        'isCompleted': isCompleted,
      };

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    String? dueDate,
    bool? isCompleted,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        dueDate: dueDate ?? this.dueDate,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}