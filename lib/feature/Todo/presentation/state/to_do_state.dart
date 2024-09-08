import 'package:equatable/equatable.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/todo_entity.dart';

enum SortOption { priority, dueDate, creationDate }

class TodoState extends Equatable {
  final bool showLoading;
  final List<Todo> todos;
  final String errorMessage;
  final SortOption currentSortOption;

  const TodoState({
    this.todos = const [],
    this.errorMessage = '',
    this.showLoading = false,
    this.currentSortOption = SortOption.creationDate,
  });

  TodoState copyWith({
    List<Todo>? todosList,
    String? error,
    bool? loading,
    SortOption? sortOption,
  }) {
    return TodoState(
      todos: todosList ?? todos,
      errorMessage: error ?? errorMessage,
      showLoading: loading ?? showLoading,
      currentSortOption: sortOption ?? currentSortOption,
    );
  }

  @override
  List<Object> get props => [
        todos,
        errorMessage,
        showLoading,
        currentSortOption,
      ];
}
