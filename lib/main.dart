import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AuthService.initialize();

  // ============================================================
  // AUTO-LOGIN FOR TESTING
  // Remove this after testing
  // ============================================================
  if (!AuthService.isLoggedIn) {
    print('🔑 Attempting auto-login...');
    final result = await AuthService.login(
      phone: '0912345678', // ← REPLACE with your test phone number
      password: 'password', // ← REPLACE with your test password
      rememberMe: true,
    );
    print('🔑 Auto-login result: ${result['success']}');
    if (result['success'] == true) {
      print('✅ Logged in as: ${AuthService.currentUser?.fullName}');
    } else {
      print('❌ Login failed: ${result['message']}');
    }
  }

  runApp(const SuperPlatformApp());
}