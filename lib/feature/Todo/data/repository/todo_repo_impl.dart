import 'package:dartz/dartz.dart';
import 'package:flutter_task_app/core/errors/failure.dart';
import 'package:flutter_task_app/core/utils/typedef.dart';
import 'package:flutter_task_app/feature/Todo/data/data%20source/local_database/todo_local_data_source.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/todo_entity.dart';
import 'package:flutter_task_app/feature/Todo/domain/repositories/todo_repo.dart';

/// Implementation of the [TodoRepository] interface, responsible for interacting
/// with the local data source.
class TodoRepositoryImpl implements TodoRepository {
  final TodoDataSource localDataSource;

  TodoRepositoryImpl(this.localDataSource);

  @override
  ResultVoid addTodo({
    required String title,
    required String description,
    required PriorityLevel priority,
    required DateTime dueDate,
  }) async {
    final todoModel = TodoModel(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate);
    try {
      await localDataSource.addTodo(todoModel);
      return const Right(null); // Success
    } catch (e) {
      return const Left(Failure(message: 'Failed to add todo')); // Failure
    }
  }

  @override
  ResultFuture<List<Todo>> getallTodo() async {
    try {
      final todoModels = await localDataSource.getAllTodos();
      final todos = todoModels
          .map((model) => Todo(
              title: model.title,
              description: model.description,
              priority: model.priority,
              dueDate: model.dueDate))
          .toList();
      return Right(todos); // Success
    } catch (e) {
      return const Left(Failure(message: 'Failed to fetch todos')); // Failure
    }
  }

  @override
  ResultVoid deleteTodo({required int todo}) async {
    try {
      await localDataSource.deleteTodo(todo); // Mapping

      return const Right(null); // Success
    } catch (e) {
      return const Left(Failure(message: 'Failed to delete todo')); // Failure
    }
  }

  @override
  ResultVoid updateTodo(
      {required int todoIndex,
      required String title,
      required String description,
      required PriorityLevel priority,
      required DateTime dueDate}) async {
    try {
      final updatedTodoModel = TodoModel(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      await localDataSource.updateTodo(todoIndex, updatedTodoModel);
      return const Right(null);
    } catch (e) {
      return const Left(Failure(message: 'Failed to update todo'));
    }
  }
}
