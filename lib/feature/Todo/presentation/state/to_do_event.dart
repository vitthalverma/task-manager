import 'package:equatable/equatable.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_state.dart';

// Events
abstract class TodoEvent extends Equatable {
  const TodoEvent();
}

class FetchTodosEvent extends TodoEvent {
  @override
  List<Object> get props => [];
}

class AddTodoEvent extends TodoEvent {
  final String title;
  final String description;
  final PriorityLevel priority;
  final DateTime dueDate;

  const AddTodoEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
  });
  @override
  List<Object> get props => [title, description, priority, dueDate];
}

class DeleteTodoEvent extends TodoEvent {
  final int todoIndex;
  const DeleteTodoEvent(this.todoIndex);
  @override
  List<Object> get props => [todoIndex];
}

class UpdateTodoEvent extends TodoEvent {
  final int todoIndex;
  final String title;
  final String description;
  final PriorityLevel priority;
  final DateTime dueDate;

  const UpdateTodoEvent(
      {required this.todoIndex,
      required this.title,
      required this.description,
      required this.priority,
      required this.dueDate});

  @override
  List<Object> get props => [todoIndex, title, description, priority, dueDate];
}

class SortTodosEvent extends TodoEvent {
  final SortOption sortOption;

  const SortTodosEvent(this.sortOption);

  @override
  List<Object> get props => [sortOption];
}

class SetReminderEvent extends TodoEvent {
  final TodoModel todo;

  const SetReminderEvent(this.todo);

  @override
  List<Object> get props => [todo];
}
