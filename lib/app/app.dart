import 'package:flutter/material.dart';

import 'app_theme.dart';

import '../features/splash/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';

class SuperPlatformApp extends StatelessWidget {
  const SuperPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Super Platform',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: ThemeMode.dark,

      routes: {"/login": (context) => const LoginScreen()},

      home: const SplashScreen(),
    );
  }
}
