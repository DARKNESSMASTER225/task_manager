import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'my_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Импортируем файл с глобальными переменными
import 'main.dart'; // Добавьте этот импорт

const String color1Key = 'color1';
const String color2Key = 'color2';
const String color3Key = 'color3';
const String color4Key = 'color4';
const String color5Key = 'color5';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

Color color1 = Colors.red;
Color color2 = Colors.blue;
Color color3 = Colors.green;
Color color4 = Colors.yellow;
Color color5 = Colors.purple;

class _SettingsPageState extends State<SettingsPage> {
  // Переменные для хранения введенных значений
  int _selectedPeriod = notification_period;
  int _selectedTime = notification_time;

  final List<int> _timeOptions = List.generate(24, (index) => index);

  @override
  void initState() {
    super.initState();
    _loadColorsFromPreferences();
  }

  Future<void> _loadColorsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      color1 = Color(prefs.getInt(color1Key) ?? Colors.red.value);
      color2 = Color(prefs.getInt(color2Key) ?? Colors.blue.value);
      color3 = Color(prefs.getInt(color3Key) ?? Colors.green.value);
      color4 = Color(prefs.getInt(color4Key) ?? Colors.yellow.value);
      color5 = Color(prefs.getInt(color5Key) ?? Colors.purple.value);
    });
  }

  Future<void> _saveColorsToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(color1Key, color1.value);
    await prefs.setInt(color2Key, color2.value);
    await prefs.setInt(color3Key, color3.value);
    await prefs.setInt(color4Key, color4.value);
    await prefs.setInt(color5Key, color5.value);
  }

  void _showColorPicker(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите цвет'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                _saveColorsToPreferences();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки цвета для разных типов задач'),
      ),
      drawer: MyDrawer(),
      body: ListView(
        children: <Widget>[
          _buildListTile(
            title: 'Временная задача',
            color: color1,
            onTap: (color) {
              setState(() {
                color1 = color;
              });
            },
          ),
          _buildListTile(
            title: 'Каждый день',
            color: color2,
            onTap: (color) {
              setState(() {
                color2 = color;
              });
            },
          ),
          _buildListTile(
            title: 'Каждую неделю',
            color: color3,
            onTap: (color) {
              setState(() {
                color3 = color;
              });
            },
          ),
          _buildListTile(
            title: 'Каждый месяц',
            color: color4,
            onTap: (color) {
              setState(() {
                color4 = color;
              });
            },
          ),
          _buildListTile(
            title: 'Каждый год',
            color: color5,
            onTap: (color) {
              setState(() {
                color5 = color;
              });
            },
          ),
          // Раздел для выбора периода
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Период уведомлений:',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold), // Увеличили размер текста
                ),
                SizedBox(height: 8.0),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Введите период',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = int.tryParse(value) ?? 0; // Обрабатываем ввод как число
                    });
                  },
                  controller: TextEditingController(text: _selectedPeriod.toString()),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      notification_period = _selectedPeriod; // Обновляем глобальную переменную
                    });
                  },
                  child: Text('Сохранить'),
                ),
              ],
            ),
          ),

          // Раздел для выбора времени (с выпадающим списком)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Время уведомлений:',
                  style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold), // Увеличили размер текста
                ),
                SizedBox(height: 8.0),
                DropdownButton<int>(
                  value: _selectedTime,
                  items: _timeOptions.map((time) {
                    return DropdownMenuItem<int>(
                      value: time,
                      child: Text(time.toString().padLeft(2, '0')), // Форматируем время как 00-23
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      notification_time = _selectedTime; // Обновляем глобальную переменную
                    });
                  },
                  child: Text('Сохранить'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Выносим повторяющийся код ListTile в отдельный метод
  Widget _buildListTile({
    required String title,
    required Color color,
    required Function(Color) onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40.0, // Увеличиваем размер круга
        height: 40.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
      title: Padding( // Добавляем отступы вокруг текста
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: TextStyle(fontSize: 22.0), // Увеличили размер текста
        ),
      ),
      onTap: () => _showColorPicker(color, onTap),
    );
  }
}