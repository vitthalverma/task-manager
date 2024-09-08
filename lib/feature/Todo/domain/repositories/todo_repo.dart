import 'package:flutter_task_app/core/utils/typedef.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/todo_entity.dart';

/// Abstract class defining a contract for interacting with Todo data.
abstract class TodoRepository {
  const TodoRepository();

  ResultVoid addTodo({
    required String title,
    required String description,
    required PriorityLevel priority,
    required DateTime dueDate,
  });

  ResultVoid deleteTodo({
    required int todo,
  });
  ResultVoid updateTodo({
    required int todoIndex,
    required String title,
    required String description,
    required PriorityLevel priority,
    required DateTime dueDate,
  });

  ResultFuture<List<Todo>> getallTodo();
}
