import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'task.dart';
import 'my_drawer.dart';

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Task> _archivedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadArchivedTasks();
  }

  Future<void> _loadArchivedTasks() async {
    final database = await _initDatabase();
    final List<Map<String, dynamic>> maps = await database.query('tasks', where: 'archive = 1');
    setState(() {
      _archivedTasks = List.generate(maps.length, (i) {
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

  Future<void> _updateTask(Task task) async {
    final database = await _initDatabase();
    await database.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    await _loadArchivedTasks();
  }

  Future<void> _deleteTask(int id) async {
    final database = await _initDatabase();
    await database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    await _loadArchivedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Архив'),
      ),
      // Добавляем Drawer
      drawer: MyDrawer(),
      body: ListView.builder(
        itemCount: _archivedTasks.length,
        itemBuilder: (context, index) {
          return TaskItem(
            task: _archivedTasks[index],
            onDelete: _deleteTask,
            onUpdate: _updateTask,
          );
        },
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(int) onDelete;
  final Function(Task) onUpdate;

  TaskItem({required this.task, required this.onDelete, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(task.name),
        subtitle: Text(task.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.undo),
              onPressed: () {
                onUpdate(Task(
                  id: task.id,
                  name: task.name,
                  description: task.description,
                  period: task.period,
                  archive: false,
                ));
              },
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
