import 'package:flutter/material.dart';
import 'my_drawer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart';
import 'archive_screen.dart';
import 'setting.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  Task? _editingTask;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final database = await _initDatabase();
    final List<Map<String, dynamic>> maps = await database.query('tasks');
    setState(() {
      _tasks = List.generate(maps.length, (i) {
        return Task(
          id: maps[i]['id'],
          name: maps[i]['name'],
          description: maps[i]['description'],
          period: maps[i]['period'],
          archive: maps[i]['archive'] == 1,
        );
      });
    });
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, period INTEGER, archive BOOLEAN)',
        );
      },
      version: 1,
    );
  }

  Future<void> _addTask(Task task) async {
    final database = await _initDatabase();
    await database.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _loadTasks();
  }

  Future<void> _updateTask(Task task) async {
    final database = await _initDatabase();
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await _loadTasks();
    _editingTask = null;
  }

  Future<void> _deleteTask(int id) async {
    final database = await _initDatabase();
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    void _showEditTaskDialog(Task task) {
      _editingTask = task;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditTaskDialog(
            task: task,
            onSave: _updateTask,
          );
        },
      );
    }

    void _showAddTaskDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddTaskDialog(_addTask);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Мои задачи',
          style: TextStyle(fontSize: 22),
        ),
      ),
      drawer: MyDrawer(),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          if (_tasks[index].archive) return Container();
          return TaskItem(
            task: _tasks[index],
            onDelete: _deleteTask,
            onUpdate: _updateTask,
            onEdit: () => _showEditTaskDialog(_tasks[index]),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
        child: SizedBox(
          width: 100,
          height: 100,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: _showAddTaskDialog,
              child: Icon(Icons.add, color: Colors.black),
              backgroundColor: Colors.green,
              shape: CircleBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final Function(Task) onSave;

  AddTaskDialog(this.onSave);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _period = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Добавить задачу',
        style: TextStyle(fontSize: 22),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Название',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название задачи';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<int>(
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Период',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                value: _period,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Временная задача', style: TextStyle(fontSize: 22, color:  Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('1 день', style: TextStyle(fontSize: 22, color:  Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: 7,
                    child: Text('7 дней', style: TextStyle(fontSize: 22, color:  Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text('30 дней', style: TextStyle(fontSize: 22, color:  Colors.black)),
                  ),
                  DropdownMenuItem(
                    value: 365,
                    child: Text('365 дней', style: TextStyle(fontSize: 22, color:  Colors.black)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _period = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Отмена', style: TextStyle(fontSize: 22)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Сохранить', style: TextStyle(fontSize: 22)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(Task(
                name: _name,
                description: _description,
                period: _period,
                archive: false,
              ));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final Function(Task) onSave;

  EditTaskDialog({required this.task, required this.onSave});

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late int _period;

  @override
  void initState() {
    super.initState();
    _name = widget.task.name;
    _description = widget.task.description;
    _period = widget.task.period;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Редактировать задачу',
        style: TextStyle(fontSize: 22),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Название',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название задачи';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Описание',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<int>(
                style: TextStyle(fontSize: 22),
                decoration: InputDecoration(
                  labelText: 'Период',
                  labelStyle: TextStyle(fontSize: 22),
                ),
                value: _period,
                items: [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Временная задача', style: TextStyle(fontSize: 22)),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('1 день', style: TextStyle(fontSize: 22)),
                  ),
                  DropdownMenuItem(
                    value: 7,
                    child: Text('7 дней', style: TextStyle(fontSize: 22)),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text('30 дней', style: TextStyle(fontSize: 22)),
                  ),
                  DropdownMenuItem(
                    value: 365,
                    child: Text('365 дней', style: TextStyle(fontSize: 22)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _period = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Отмена', style: TextStyle(fontSize: 22)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Сохранить', style: TextStyle(fontSize: 22)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(Task(
                id: widget.task.id,
                name: _name,
                description: _description,
                period: _period,
                archive: widget.task.archive,
              ));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(int) onDelete;
  final Function(Task) onUpdate;
  final Function() onEdit;

  TaskItem({
    required this.task,
    required this.onDelete,
    required this.onUpdate,
    required this.onEdit,
  });

  Color _getPeriodColor() {
    switch (task.period) {
      case 1:
        return color2.withOpacity(0.5);
      case 7:
        return color3.withOpacity(0.5);
      case 30:
        return color4.withOpacity(0.5);
      case 365:
        return color5.withOpacity(0.5);
      default:
        return color1.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getPeriodColor(),
      child: ListTile(
        title: Text(
          task.name,
          style: TextStyle(fontSize: 22),
        ),
        subtitle: Text(
          task.description,
          style: TextStyle(fontSize: 22),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (task.period > 0) {
                  onUpdate(Task(
                    id: task.id,
                    name: task.name,
                    description: task.description,
                    period: task.period,
                    archive: true,
                  ));
                } else {
                  onUpdate(Task(
                    id: task.id,
                    name: task.name,
                    description: task.description,
                    period: task.period,
                    archive: true,
                  ));
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                onDelete(task.id!);
              },
            ),
          ],
        ),
      ),
    );
  }
}