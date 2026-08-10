import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;

  const AuthButton({
    super.key,

    required this.text,

    required this.onPressed,

    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,

      width: double.infinity,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : Colors.white,

          foregroundColor: outlined ? Colors.white : Colors.black,

          side: outlined ? const BorderSide(color: Colors.white24) : null,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        child: Text(
          text,

          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
