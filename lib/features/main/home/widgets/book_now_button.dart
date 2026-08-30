import 'package:flutter/material.dart';

import '../../../../data/dummy/hotel_dummy.dart';
import '../../../../data/models/hotel.dart';
import '../../../../data/models/room.dart';
import '../../../../data/services/room_service.dart';
import '../../booking/screens/hotel_details_screen.dart';

class BookNowButton extends StatefulWidget {
  final int hotelId;
  final Hotel? hotel;

  const BookNowButton({
    super.key,
    required this.hotelId,
    this.hotel,
  });

  @override
  State<BookNowButton> createState() => _BookNowButtonState();
}

class _BookNowButtonState extends State<BookNowButton> {
  bool _isLoading = false;

  Future<void> _handleBookTap() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    List<Room>? rooms;
    try {
      rooms = await RoomService.getRoomsByHotel(widget.hotelId);
    } catch (e) {
      debugPrint('RoomService exception on book tap: $e');
      rooms = null;
    }

    if (!mounted) return;

    final hotel = widget.hotel ??
        hotels.firstWhere(
          (h) => h.id == widget.hotelId,
          orElse: () => Hotel(
            id: widget.hotelId,
            name: 'Hotel #${widget.hotelId}',
            image: 'assets/images/r1.jpg',
            video: '',
            description: 'Luxury hotel accommodations.',
            location: 'Ethiopia',
            rating: 4.8,
            price: 120,
            likes: 0,
            comments: 0,
            shares: 0,
          ),
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HotelDetailScreen(
          hotel: hotel,
          initialRooms: rooms,
        ),
      ),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleBookTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade400, Colors.pink.shade600],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Book',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
