import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final String image;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.image,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: disabled ? Colors.white70 : Colors.white,
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
              Opacity(
                opacity: disabled ? 0.5 : 1.0,
                child: Image.asset(
                  image,
                  width: 26,
                  height: 26,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.login,
                      size: 26,
                      color: Colors.black54,
                    );
                  },
                ),
              ),

              const SizedBox(width: 15),

              Text(
                text,
                style: TextStyle(
                  color: disabled ? Colors.black54 : Colors.black,
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
