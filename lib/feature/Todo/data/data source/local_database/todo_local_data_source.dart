import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:hive/hive.dart';

abstract class TodoDataSource {
  Future<void> addTodo(TodoModel todo);
  Future<void> deleteTodo(int todoModel);
  Future<void> updateTodo(int todoIndex, TodoModel updatedTodo);
  Future<List<TodoModel>> getAllTodos();
}

class HiveTodoDataSource implements TodoDataSource {
  final Box<TodoModel> todoBox;

  HiveTodoDataSource(this.todoBox);

  @override
  Future<void> addTodo(TodoModel todo) async {
    await todoBox.add(todo);
  }

  /// Deletes a Todo from the data source based on the provided [todoIndex].
  @override
  Future<void> deleteTodo(int todoIndex) async {
    final keys = todoBox.keys.toList();
    final index =
        todoIndex >= 0 && todoIndex < keys.length ? keys[todoIndex] : null;
    if (index != null) {
      await todoBox.delete(index);
    } else {
      throw Exception('Invalid todo index');
    }
  }

  @override
  Future<List<TodoModel>> getAllTodos() async {
    return todoBox.values.toList();
  }

  @override
  Future<void> updateTodo(int todoIndex, TodoModel updatedTodo) async {
    final keys = todoBox.keys.toList();
    final index =
        todoIndex >= 0 && todoIndex < keys.length ? keys[todoIndex] : null;
    if (index != null) {
      await todoBox.put(index, updatedTodo);
    } else {
      throw Exception('Invalid todo index');
    }
  }
}
