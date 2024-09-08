import 'package:equatable/equatable.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';

class Todo extends Equatable {
  final String title;
  final String description;
  final PriorityLevel priority;
  final DateTime dueDate;
  final DateTime createdAt;

  Todo({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [title, description, priority, dueDate, createdAt];
}
