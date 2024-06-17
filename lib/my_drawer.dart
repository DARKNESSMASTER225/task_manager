import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Добавляем список пунктов меню
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.greenAccent,
            ),
            child: Text('TASK MANAGER', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)), // Увеличили размер шрифта
          ),
          ListTile(
            title: Text('Основные задачи', style: TextStyle(fontSize: 22)), // Увеличили размер шрифта
            onTap: () {
              Navigator.pushReplacementNamed(context, '/'); // Возвращаемся на домашний экран
            },
          ),
          ListTile(
            title: Text('Архив задач', style: TextStyle(fontSize: 22)), // Увеличили размер шрифта
            onTap: () {
              Navigator.pushReplacementNamed(context, '/archive'); // Переход на экран профиля
            },
          ),
          ListTile(
            title: Text('Календарь', style: TextStyle(fontSize: 22)), // Увеличили размер шрифта
            onTap: () {
              Navigator.pushReplacementNamed(context, '/stat'); // Переход на экран профиля
            },
          ),
          ListTile(
            title: Text('Напоминания', style: TextStyle(fontSize: 22)), // Увеличили размер шрифта
            onTap: () {
              Navigator.pushReplacementNamed(context, '/alarm'); // Переход на экран профиля
            },
          ),
          ListTile(

            title: Text('Настройки', style: TextStyle(fontSize: 22)), // Увеличили размер шрифта
            onTap: () {
              Navigator.pushReplacementNamed(context, '/setting'); // Переход на экран профиля
            },
          ),
        ],
      ),
    );
  }
}