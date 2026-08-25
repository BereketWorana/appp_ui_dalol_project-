import 'package:flutter/material.dart';

import '../../../../../data/models/hotel.dart';
import '../../../../../data/dummy/room_dummy.dart';
import '../../../../../data/models/room.dart';

import '../widgets/room_card.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final hotelRooms = rooms
        .where((room) => room.merchantId == hotel.id)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black,

              expandedHeight: 260,

              pinned: true,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),

                onPressed: () => Navigator.pop(context),
              ),

              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,

                  children: [
                    Image.asset(hotel.image, fit: BoxFit.cover),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,

                          end: Alignment.bottomCenter,

                          colors: [Colors.transparent, Colors.black],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hotel.name,

                            style: const TextStyle(
                              color: Colors.white,

                              fontSize: 26,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Icon(Icons.verified, color: Colors.blue),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Addis Ababa, Ethiopia",

                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber),

                        SizedBox(width: 5),

                        Text(
                          "4.8  (1250 reviews)",

                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "About Hotel",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${hotel.name} provides luxury rooms, premium services, restaurants and comfortable stays for travelers.",

                      style: const TextStyle(
                        color: Colors.white70,

                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Available Rooms",

                      style: TextStyle(
                        color: Colors.white,

                        fontSize: 21,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                Room room = hotelRooms[index];

                return RoomCard(room: room, hotel: hotel);
              }, childCount: hotelRooms.length),
            ),
          ],
        ),
      ),
    );
  }
}
