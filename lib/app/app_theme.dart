import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),

      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.white,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(brightness: Brightness.light, primaryColor: Colors.black);
  }
}
