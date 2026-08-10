import 'package:flutter/material.dart';

import '../../../../../data/models/user.dart';
import '../../../../../data/models/room.dart';
import '../../../../../core/services/auth_service.dart';

import 'booking_success_screen.dart';

class BookingInformationScreen extends StatefulWidget {
  final User hotel;

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

  DateTime? checkIn;

  DateTime? checkOut;

  int guests = 1;

  String paymentMethod = "Telebirr";

  @override
  void initState() {
    super.initState();

    final user = AuthService.currentUser;

    nameController = TextEditingController(text: user?.fullName ?? "");

    emailController = TextEditingController(text: user?.email ?? "");

    phoneController = TextEditingController(text: user?.phone ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();

    emailController.dispose();

    phoneController.dispose();

    super.dispose();
  }

  Future<void> selectDate(bool isCheckIn) async {
    final date = await showDatePicker(
      context: context,

      firstDate: DateTime.now(),

      lastDate: DateTime(2030),

      initialDate: DateTime.now(),
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
              widget.hotel.fullName,

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

            const SizedBox(height: 25),

            Text(
              "Total: ${widget.room.pricePerNight * guests} ETB",

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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(
                      builder: (_) => BookingSuccessScreen(hotel: widget.hotel),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,

                  foregroundColor: Colors.black,

                  padding: const EdgeInsets.all(15),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                child: const Text(
                  "Pay Now",

                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controller,

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
