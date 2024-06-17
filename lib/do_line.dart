import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'my_drawer.dart'; // Импортируем файл с боковым меню

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _notes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Календарь'),
      ),
      // Добавляем Drawer
      drawer: MyDrawer(),
      body: Column(
        children: [
          // Улучшенный календарь с помощью TableCalendar
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: (day) {
              return _notes[day] ?? [];
            },
          ),
          SizedBox(height: 20),
          // Улучшенное отображение выбранной даты
          Text(
            _selectedDay != null
                ? 'Выбранная дата: ${DateFormat('dd.MM.yyyy').format(_selectedDay!)}'
                : 'Выберите дату',
            style: TextStyle(fontSize: 18),
          ),
          // Улучшенное поле для ввода заметок
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Добавить заметку',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty && _selectedDay != null) {
                  setState(() {
                    _notes.update(
                      _selectedDay!,
                          (existingNotes) => [...existingNotes, value],
                      ifAbsent: () => [value],
                    );
                  });
                }
              },
            ),
          ),
          // Улучшенное отображение списка заметок
          Expanded(
            child: ListView.builder(
              itemCount: _notes[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(_notes[_selectedDay]![index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}