import 'package:flutter/material.dart';
import 'my_drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: Center(
        child: Text('Содержимое профиля'),
      ),
      drawer: MyDrawer(), // Добавляем боковое меню
    );
  }
}