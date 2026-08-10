import 'package:flutter/material.dart';

class DealBanner extends StatelessWidget {
  const DealBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        image: const DecorationImage(
          image: AssetImage("assets/images/r11.jpg"),
          fit: BoxFit.cover,
        ),
      ),

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: .75),
              Colors.black.withValues(alpha: .35),
            ],
          ),
        ),

        padding: const EdgeInsets.all(22),

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    "Special Offer",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Save up to\n30%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Book today and enjoy exclusive discounts.",
                    style: TextStyle(color: Colors.white60),
                  ),

                  const SizedBox(height: 18),

                  ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),

                    child: const Text("View Deals"),
                  ),
                ],
              ),
            ),

            Container(
              width: 90,
              height: 90,

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: const Center(
                child: Text(
                  "30%\nOFF",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
