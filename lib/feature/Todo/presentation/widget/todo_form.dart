import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_task_app/core/utils/string_functions.dart';
import 'package:flutter_task_app/feature/Todo/data/model/todo_model.dart';
import 'package:flutter_task_app/feature/Todo/domain/entity/priority_level.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_bloc.dart';
import 'package:flutter_task_app/feature/Todo/presentation/state/to_do_event.dart';
import 'package:intl/intl.dart';

class TodoForm extends StatefulWidget {
  final TodoModel? todo;
  final int? todoIndex;
  const TodoForm({super.key, this.todo, this.todoIndex});

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late PriorityLevel _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.todo?.description ?? '');
    _dueDate =
        widget.todo?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _priority = widget.todo?.priority ?? PriorityLevel.medium;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          DropdownButtonFormField<PriorityLevel>(
            value: _priority,
            onChanged: (PriorityLevel? newValue) {
              setState(() {
                _priority = newValue!;
              });
            },
            items: PriorityLevel.values.map((PriorityLevel priority) {
              return DropdownMenuItem<PriorityLevel>(
                value: priority,
                child: Text(priority.toString().split('.').last),
              );
            }).toList(),
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          ListTile(
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && picked != _dueDate) {
                setState(() {
                  _dueDate = picked;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.todo == null) {
                context.read<TodoBloc>().add(AddTodoEvent(
                      title: StringFunctions()
                          .capitalizeFirstLetter(_titleController.text.trim()),
                      description: StringFunctions().capitalizeFirstLetter(
                          _descriptionController.text.trim()),
                      priority: _priority,
                      dueDate: _dueDate,
                    ));
              } else {
                context.read<TodoBloc>().add(UpdateTodoEvent(
                      todoIndex: widget.todoIndex!,
                      title: StringFunctions()
                          .capitalizeFirstLetter(_titleController.text.trim()),
                      description: StringFunctions().capitalizeFirstLetter(
                          _descriptionController.text.trim()),
                      priority: _priority,
                      dueDate: _dueDate,
                    ));
              }
              Navigator.pop(context);
            },
            child: Text(widget.todo == null ? 'Add Todo' : 'Update Todo'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
