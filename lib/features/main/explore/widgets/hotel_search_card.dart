import 'package:flutter/material.dart';

class HotelSearchCard extends StatelessWidget {
  const HotelSearchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              searchTile(
                Icons.location_on_outlined,
                "Destination",
                "Where are you going?",
              ),

              const Divider(),

              Row(
                children: [
                  Expanded(
                    child: searchTile(
                      Icons.calendar_today,
                      "Check In",
                      "26 Jun",
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: searchTile(
                      Icons.calendar_today,
                      "Check Out",
                      "27 Jun",
                    ),
                  ),
                ],
              ),

              const Divider(),

              searchTile(Icons.people_outline, "Guests", "2 Adults • 1 Room"),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  icon: const Icon(Icons.search),

                  label: const Text(
                    "Search Hotels",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.black),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
