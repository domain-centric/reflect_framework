import 'package:flutter/material.dart';

import 'gui/gui.dart';

void main() {
  runApp(MyFirstApp());
}

class MyFirstApp extends ReflectGuiApplication {
  @override
  ThemeData get lightTheme =>
      ThemeData(primarySwatch: Colors.red, brightness: Brightness.light);

  @override
  ThemeData get darkTheme =>
      ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark);
}
