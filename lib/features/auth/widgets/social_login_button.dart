import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,

    required this.text,

    required this.image,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 52,

      child: InkWell(
        borderRadius: BorderRadius.circular(18),

        onTap: onPressed,

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(18),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),

                blurRadius: 8,

                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Image.asset(image, width: 26, height: 26),

              const SizedBox(width: 15),

              Text(
                text,

                style: const TextStyle(
                  color: Colors.black,

                  fontSize: 16,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
