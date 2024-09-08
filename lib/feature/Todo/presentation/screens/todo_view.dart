import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_app/core/app/app_colors.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/todo_entity.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_bloc.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_event.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_state.dart';
import 'package:flutter_task_app/feature/Todo/presentation/widget/todo_form.dart';
import 'package:intl/intl.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final _searchController = TextEditingController();
  List<Todo> _filteredTodos = [];
  @override
  void initState() {
    context.read<TodoBloc>().add(FetchTodosEvent());
    _searchController.addListener(_filterTodos);
    super.initState();
  }

  void _showAddTodoDialog(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return const TodoForm();
      },
    );
  }

  void _filterTodos() {
    final String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTodos = context.read<TodoBloc>().state.todos.where((todo) {
        return todo.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showEditTodoDialog(
      BuildContext context, TodoModel todo, int todoIndex) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return TodoForm(todo: todo, todoIndex: todoIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Task Manager',
            style: TextStyle(color: AppColors.whiteColor),
          ),
          actions: [
            PopupMenuButton<SortOption>(
              iconColor: AppColors.whiteColor,
              onSelected: (SortOption result) {
                context.read<TodoBloc>().add(SortTodosEvent(result));
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<SortOption>>[
                const PopupMenuItem<SortOption>(
                  value: SortOption.priority,
                  child: Text('Sort by Priority'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.dueDate,
                  child: Text('Sort by Due Date'),
                ),
                const PopupMenuItem<SortOption>(
                  value: SortOption.creationDate,
                  child: Text('Sort by Creation Date'),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                style: const TextStyle(color: AppColors.greyColor),
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Tasks...',
                  hintStyle: const TextStyle(color: AppColors.greyColor),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.greyColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundColor,
                ),
              ),
            ),
          ),
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state.showLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.errorMessage.isNotEmpty) {
              return const Center(child: Text('Error loading todos'));
            }
            final todos =
                _searchController.text.isEmpty ? state.todos : _filteredTodos;
            return todos.isEmpty
                ? const Center(
                    child: Text('No todos yet.'),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 25, right: 15),
                    child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 10),
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              todos[index].title,
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todos[index].description,
                                  style: const TextStyle(
                                    color: AppColors.greyColor,
                                  ),
                                ),
                                Text(
                                  'Due: ${DateFormat('yyyy-MM-dd').format(todos[index].dueDate)}',
                                  style: const TextStyle(
                                      color: AppColors.gradient3),
                                ),
                                Text(
                                  'Priority: ${todos[index].priority.toString().split('.').last}',
                                  style: const TextStyle(
                                    color: AppColors.gradient2,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: AppColors.whiteColor),
                                  onPressed: () {
                                    final todoModel = TodoModel(
                                      title: todos[index].title,
                                      description: todos[index].description,
                                      priority: todos[index].priority,
                                      dueDate: todos[index].dueDate,
                                    );
                                    _showEditTodoDialog(
                                        context, todoModel, index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    context
                                        .read<TodoBloc>()
                                        .add(DeleteTodoEvent(index));
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              final todoModel = TodoModel(
                                title: todos[index].title,
                                description: todos[index].description,
                                priority: todos[index].priority,
                                dueDate: todos[index].dueDate,
                              );
                              _showEditTodoDialog(context, todoModel, index);
                            });
                      },
                    ),
                  );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
