import 'dart:async';
import 'dart:math';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/todo_entity.dart';
import 'package:flutter_task_app/feature/Todo/domain/repositories/todo_repo.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_event.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_state.dart';

/*
  ###########  Using REPOSITORY insted of USECASES to reduce complexity ############
 */

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _todoRepository;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  TodoBloc(this._todoRepository, this._notificationsPlugin)
      : super(const TodoState()) {
    on<FetchTodosEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<SortTodosEvent>(_onSortTodos);
    on<SetReminderEvent>(_onSetReminder);
  }

  FutureOr<void> _onLoadTodos(
    FetchTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final result = await _todoRepository.getallTodo();
      result.fold(
        (failure) => emit(state.copyWith(error: failure.message)),
        (todos) {
          final todoModelList = todos
              .map((todo) => TodoModel(
                    title: todo.title,
                    description: todo.description,
                    priority: todo.priority,
                    dueDate: todo.dueDate,
                  ))
              .toList();
          _sortTodos(todoModelList, state.currentSortOption);
          emit(state.copyWith(todosList: todos, error: ''));
        },
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onAddTodo(
    AddTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    debugPrint("todo  ${event.title}");
    try {
      await _todoRepository.addTodo(
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      _scheduleNotification(event.title, event.dueDate);
      add(FetchTodosEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _todoRepository.deleteTodo(todo: event.todoIndex);

      add(FetchTodosEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await _todoRepository.updateTodo(
        todoIndex: event.todoIndex,
        title: event.title,
        description: event.description,
        priority: event.priority,
        dueDate: event.dueDate,
      );
      add(FetchTodosEvent());
      _scheduleNotification(event.title, event.dueDate);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  FutureOr<void> _onSortTodos(SortTodosEvent event, Emitter<TodoState> emit) {
    final todoModelList = state.todos
        .map((todo) => TodoModel(
              title: todo.title,
              description: todo.description,
              priority: todo.priority,
              dueDate: todo.dueDate,
            ))
        .toList();
    final sortedTodos = _sortTodos(todoModelList, event.sortOption);
    final soretedTodoModelList = sortedTodos
        .map((todo) => Todo(
              title: todo.title,
              description: todo.description,
              priority: todo.priority,
              dueDate: todo.dueDate,
            ))
        .toList();
    emit(state.copyWith(
        todosList: soretedTodoModelList, sortOption: event.sortOption));
  }

  List<TodoModel> _sortTodos(List<TodoModel> todos, SortOption sortOption) {
    switch (sortOption) {
      case SortOption.priority:
        return todos
          ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case SortOption.dueDate:
        return todos..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      case SortOption.creationDate:
        return todos..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  FutureOr<void> _onSetReminder(
      SetReminderEvent event, Emitter<TodoState> emit) async {
    await _scheduleNotification(event.todo.title, event.todo.dueDate);
  }

  Future<void> _scheduleNotification(String title, DateTime dueDate) async {
    // Initialize timezone data
    tz.initializeTimeZones();

    final scheduledTime = tz.TZDateTime.from(dueDate, tz.local)
        .subtract(const Duration(hours: 1));

    // Ensure the scheduled time is in the future
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Scheduled time is in the past. Skipping notification.');
      return;
    }

    // Android specific notification details
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'todo_reminders', // Channel ID
      'Todo Reminders', // Channel name
      channelDescription:
          'Reminder notifications for your todos.', // Channel description
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS specific notification details
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true, // Display alert
      presentBadge: true, // Update badge count
      presentSound: true, // Play sound
    );

    // Platform-specific notification details
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.zonedSchedule(
      Random().nextInt(100000),
      'Task Due Soon',
      'Your task "$title" is due soon!',
      scheduledTime,
      platformChannelSpecifics,
      androidAllowWhileIdle:
          true, // Allows notification to show when the device is idle on Android
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Adjust based on your requirement
    );

    print('Notification scheduled for task "$title" at $scheduledTime');
  }
}
