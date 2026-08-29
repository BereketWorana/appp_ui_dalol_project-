import 'package:flutter/material.dart';
import '../../../../data/models/hotel.dart';
import 'hotel_details_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Hotel hotel;
  final String? bookingReference;

  const BookingSuccessScreen({
    super.key, 
    required this.hotel,
    this.bookingReference,
  });

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailScreen(hotel: widget.hotel),
          ),
        );
      }
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
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 60),
            ),
            const SizedBox(height: 25),
            const Text(
              "Booking Submitted Successfully",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your request has been sent to ${widget.hotel.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            if (widget.bookingReference != null) ...[
              const SizedBox(height: 8),
              Text(
                "Reference: ${widget.bookingReference}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 15),
            const Text(
              "Returning to hotel page...",
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
