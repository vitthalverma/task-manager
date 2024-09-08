// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final PriorityLevel priority;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final DateTime createdAt;

  TodoModel({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
