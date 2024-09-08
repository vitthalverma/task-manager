import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_task_app/feature/Todo/data/data%20source/local_database/todo_local_data_source.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/data/repository/todo_repo_impl.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:flutter_task_app/feature/Todo/domain/repositories/todo_repo.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialization of Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TodoModelAdapter());
  Hive.registerAdapter(PriorityLevelAdapter());
  var box = await Hive.openBox<TodoModel>('todo');

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await notificationsPlugin.initialize(initializationSettings);

  sl.registerFactory(() => notificationsPlugin);

  // Repository registrations
  sl.registerFactory<TodoDataSource>(() => HiveTodoDataSource(box));
  sl.registerFactory<TodoRepository>(() => TodoRepositoryImpl(sl()));
  sl.registerLazySingleton(() => TodoBloc(sl(), sl()));
}
