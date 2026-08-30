import 'package:flutter/material.dart';
import '../../../../data/models/hotel.dart';
import '../../../../data/models/room.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/booking_repository.dart';
import 'booking_success_screen.dart';

class BookingInformationScreen extends StatefulWidget {
  final Hotel hotel;
  final Room room;

  const BookingInformationScreen({
    super.key,
    required this.hotel,
    required this.room,
  });

  @override
  State<BookingInformationScreen> createState() =>
      _BookingInformationScreenState();
}

class _BookingInformationScreenState extends State<BookingInformationScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController specialRequestsController;

  DateTime? checkIn;
  DateTime? checkOut;
  int guests = 1;
  String paymentMethod = "Telebirr";
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;

    // Pre-fill from AuthService if user is logged in
    nameController = TextEditingController(text: user?.fullName ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    phoneController = TextEditingController(text: user?.phone ?? "");
    specialRequestsController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> selectDate(bool isCheckIn) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (date != null) {
      setState(() {
        if (isCheckIn) {
          checkIn = date;
        } else {
          checkOut = date;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    // Validate
    if (checkIn == null || checkOut == null) {
      _showError('Please select check-in and check-out dates');
      return;
    }

    if (checkOut!.isBefore(checkIn!) || checkOut!.isAtSameMomentAs(checkIn!)) {
      _showError('Check-out date must be after check-in date');
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showError('Please fill in all guest information');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('🔄 ===== SUBMITTING GUEST BOOKING =====');
      print('🔄 Room ID: ${widget.room.id}');
      print('🔄 Hotel ID: ${widget.hotel.id}');
      
      final response = await BookingRepository.createBooking(
        roomId: widget.room.id,
        hotelId: widget.hotel.id,
        checkIn: checkIn!.toIso8601String().split('T').first,
        checkOut: checkOut!.toIso8601String().split('T').first,
        guestName: nameController.text,
        guestEmail: emailController.text,
        guestPhone: phoneController.text,
        adults: guests,
        children: 0,
        rooms: 1,
        totalPrice: widget.room.pricePerNight * guests,
        paymentMethod: paymentMethod.toLowerCase().replaceAll(' ', '_'),
        specialRequests: specialRequestsController.text.isNotEmpty
            ? specialRequestsController.text
            : null,
        userId: AuthService.isLoggedIn ? AuthService.userId : null, // Optional
      );

      debugPrint('🔄 Booking Response: $response');

      if (response['success'] != true) {
        final serverMessage = response['message']?.toString();
        _showError(
          (serverMessage != null && serverMessage.isNotEmpty)
              ? serverMessage
              : 'Booking failed. Please try again.',
        );
        return;
      }

      final bookingRef = response['booking_reference']?.toString() ??
          response['data']?['booking_reference']?.toString() ??
          response['data']?['reference']?.toString() ??
          '';

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            hotel: widget.hotel,
            bookingReference: bookingRef.isNotEmpty ? bookingRef : null,
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Booking API error: $e');
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _showError(
        (errorMessage.isNotEmpty && !errorMessage.startsWith('Instance of'))
            ? errorMessage
            : 'Booking failed. Please check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Booking Information",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.hotel.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.room.roomType,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 25),
            const Text(
              "Guest Information",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _field("Full Name", nameController),
            _field("Email", emailController),
            _field("Phone", phoneController),
            const SizedBox(height: 25),
            const Text(
              "Stay Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _dateBox(
              title: "Check In",
              date: checkIn,
              onTap: () => selectDate(true),
            ),
            const SizedBox(height: 12),
            _dateBox(
              title: "Check Out",
              date: checkOut,
              onTap: () => selectDate(false),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Guests",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (guests > 1) {
                          setState(() {
                            guests--;
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "$guests",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          guests++;
                        });
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Payment Method",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(
                    paymentMethod,
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _field("Special Requests (Optional)", specialRequestsController,
                maxLines: 2),
            const SizedBox(height: 15),
            Text(
              "Total: ${(widget.room.pricePerNight * guests).toStringAsFixed(2)} ETB",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String title, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF181818),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dateBox({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text(
              date == null
                  ? "Select Date"
                  : "${date.day}/${date.month}/${date.year}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
