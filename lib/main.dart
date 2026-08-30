import 'package:flutter/material.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'app/app.dart';
import 'core/services/auth_service.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Registers fvp as the video_player backend ONLY on platforms without an
  // official implementation (Linux, Windows). Android/iOS/web keep using
  // their existing official video_player backends, untouched.
  fvp.registerWith(options: {'platforms': ['linux', 'windows']});
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
