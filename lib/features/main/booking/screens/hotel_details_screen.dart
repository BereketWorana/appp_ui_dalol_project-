import 'package:flutter/material.dart';
import '../../../../data/models/hotel.dart';
import '../../../../data/models/room.dart' as models;
import '../../../../data/repositories/room_repository.dart';
import '../widgets/room_card.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  List<models.Room> _rooms = [];
  bool _isLoading = true;
  String? _error;
  String _debugInfo = '';

  // Use dates that we know work from the API test
  final String _checkIn = '2026-09-01';
  final String _checkOut = '2026-09-05';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _debugInfo = '';
    });

    try {
      print('🔍 ===== STARTING ROOM LOAD =====');
      print('🔍 Hotel: ${widget.hotel.name}');
      print('🔍 Hotel ID: ${widget.hotel.id}');
      print('🔍 Check-in: $_checkIn');
      print('🔍 Check-out: $_checkOut');

      // First, let's test the API directly from here
      final response = await RoomRepository.checkAvailabilityByHotel(
        hotelId: widget.hotel.id,
        checkIn: _checkIn,
        checkOut: _checkOut,
        rooms: 1,
      );

      print('📦 RAW API RESPONSE:');
      print('📦 $response');

      // Check if response has data
      if (response['success'] == true) {
        final roomsData = response['available_rooms'];
        print('📦 available_rooms type: ${roomsData.runtimeType}');
        print('📦 available_rooms length: ${roomsData?.length ?? 0}');
        print('📦 available_rooms data: $roomsData');
        
        if (roomsData != null && roomsData is List && roomsData.isNotEmpty) {
          // Parse rooms
          final List<models.Room> parsedRooms = [];
          for (var data in roomsData) {
            try {
              final room = models.Room.fromJson(data);
              parsedRooms.add(room);
              print('✅ Parsed room: ${room.name} (ID: ${room.id})');
            } catch (e) {
              print('❌ Failed to parse room: $e');
              print('❌ Room data: $data');
            }
          }
          
          setState(() {
            _rooms = parsedRooms;
            _isLoading = false;
            _debugInfo = '✅ Found ${parsedRooms.length} rooms\n'
                         'Hotel ID: ${widget.hotel.id}\n'
                         'Dates: $_checkIn to $_checkOut';
          });
        } else {
          print('⚠️ No rooms in available_rooms');
          setState(() {
            _rooms = [];
            _isLoading = false;
            _debugInfo = '⚠️ No rooms available\n'
                         'Hotel ID: ${widget.hotel.id}\n'
                         'Dates: $_checkIn to $_checkOut\n'
                         'Response: ${response.toString()}';
          });
        }
      } else {
        print('❌ API returned success: false');
        print('❌ Message: ${response['message']}');
        setState(() {
          _error = 'API Error: ${response['message'] ?? 'Unknown error'}';
          _isLoading = false;
          _debugInfo = 'Response: ${response.toString()}';
        });
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
        _debugInfo = 'Exception: $e\n'
                     'Hotel ID: ${widget.hotel.id}\n'
                     'Dates: $_checkIn to $_checkOut';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Hotel Detail', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                    widget.hotel.image.startsWith('http')
                        ? Image.network(
                            widget.hotel.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.hotel,
                                color: Colors.white54,
                                size: 80,
                              ),
                            ),
                          )
                        : Image.asset(
                            widget.hotel.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.hotel,
                                color: Colors.white54,
                                size: 80,
                              ),
                            ),
                          ),
                    Container(
                      decoration: const BoxDecoration(
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
                    Text(
                      widget.hotel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.hotel.location}, Ethiopia",
                      style: const TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 5),
                        Text(
                          "${widget.hotel.rating}  (1250 reviews)",
                          style: const TextStyle(color: Colors.white),
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
                      widget.hotel.description.isNotEmpty
                          ? widget.hotel.description
                          : "${widget.hotel.name} provides luxury rooms, premium services, restaurants and comfortable stays for travelers.",
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
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orange, size: 60),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _debugInfo,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRooms,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_rooms.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hotel, color: Colors.white38, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        'No rooms available',
                        style: TextStyle(color: Colors.white54, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _debugInfo,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRooms,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final room = _rooms[index];
                    return RoomCard(room: room, hotel: widget.hotel);
                  },
                  childCount: _rooms.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
