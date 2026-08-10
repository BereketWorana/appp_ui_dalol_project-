import 'dart:async';
import 'package:flutter/material.dart';
import '../main/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      // later:
      // check login status here

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConsumerMainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Temporary logo
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),

                color: Colors.white,
              ),

              child: const Icon(Icons.hotel, size: 60, color: Colors.black),
            ),

            const SizedBox(height: 25),

            const Text(
              "SUPER PLATFORM",

              style: TextStyle(
                color: Colors.white,

                fontSize: 24,

                fontWeight: FontWeight.bold,

                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
