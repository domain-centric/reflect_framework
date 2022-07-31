import 'package:flutter/material.dart';

import 'gui/gui.dart';

void main() {
  runApp(const MyFirstApp());
}

class MyFirstApp extends ReflectGuiApplication {
  const MyFirstApp({Key? key}) : super(key: key);

  @override
  ThemeData get lightTheme =>
      ThemeData(primarySwatch: Colors.red, brightness: Brightness.light);

  @override
  ThemeData get darkTheme =>
      ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark);
}
