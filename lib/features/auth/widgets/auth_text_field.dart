import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,

    required this.hint,

    required this.icon,

    required this.controller,

    this.obscure = false,

    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),

      child: TextField(
        controller: controller,

        obscureText: obscure,

        keyboardType: keyboardType,

        style: const TextStyle(color: Colors.white, fontSize: 16),

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: const TextStyle(color: Colors.white54),

          prefixIcon: Icon(icon, color: Colors.white70),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
