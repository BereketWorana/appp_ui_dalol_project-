import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/room.dart';
import '../../../../data/services/room_service.dart';
import '../../../main/booking/screens/add_room_screen.dart';

// ================================================================
// MY ROOMS CONTENT — Hotel Owner Room Management
// ================================================================
//
// ⚠️  HOTEL-OWNERSHIP BLOCKER (documented 2026-08-30):
//
// The backend's login response does not include which hotel(s) the
// authenticated merchant owns. The User model therefore has no hotelId
// field. Until the backend is updated to include hotel_id in the user
// profile/login response, we cannot reliably scope this screen to
// "rooms owned by me" via hotel ID alone.
//
// Current workaround: the screen shows an informative blocker state
// rather than silently fetching wrong rooms or hardcoding an ID.
// Once hotel_id is available on AuthService.currentUser, replace the
// blocker guard with:
//     final int hotelId = AuthService.currentUser!.hotelId!;
//
// ================================================================

class MyRoomsContent extends StatefulWidget {
  const MyRoomsContent({super.key});

  @override
  State<MyRoomsContent> createState() => _MyRoomsContentState();
}

class _MyRoomsContentState extends State<MyRoomsContent> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;

  // ----------------------------------------------------------------
  // Attempt to derive a hotel ID from session data.
  // Currently the User model does not expose hotelId — this will
  // be null until the backend sends hotel_id in the login response.
  // ----------------------------------------------------------------
  int? get _ownerHotelId {
    // TODO: Replace with AuthService.currentUser?.hotelId
    // once the backend returns hotel_id in the user login/profile payload.
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final hotelId = _ownerHotelId;
    if (hotelId == null) {
      // Ownership blocker: hotel_id not available yet.
      // Do not set _error — handled as a distinct UI state below.
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final rooms = await RoomService.getRoomsByHotel(hotelId);
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _error = msg.isNotEmpty ? msg : 'Failed to load rooms';
          _isLoading = false;
        });
      }
    }
  }

  // ----------------------------------------------------------------
  // EDIT ROOM
  // ----------------------------------------------------------------
  Future<void> _openEditRoom(Room room) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRoomScreen(
          hotelId: room.hotelId,
          editRoom: room, // edit mode
        ),
      ),
    );
    if (result == true) {
      _loadRooms();
    }
  }

  // ----------------------------------------------------------------
  // DELETE ROOM
  // ----------------------------------------------------------------
  Future<void> _deleteRoom(Room room) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Delete Room',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${room.name}"?\n\nThis action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await RoomService.deleteRoom(room.id);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${room.name}" deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadRooms();
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete room: ${msg.isNotEmpty ? msg : "Unknown error"}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ---- Loading ----
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // ---- Hotel-ownership blocker state ----
    if (_ownerHotelId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hotel_outlined, color: Colors.white24, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Hotel Link Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your hotel ID is not included in the session data yet. '
                'This is a known backend limitation — the login response '
                'does not return hotel_id. Once fixed, this screen will '
                'automatically load your rooms.',
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'In the meantime, you can add rooms by opening a hotel from the feed.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // ---- Error + Retry ----
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white54, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadRooms,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---- Room list ----
    return RefreshIndicator(
      onRefresh: _loadRooms,
      color: Colors.white,
      backgroundColor: const Color(0xFF1E1E1E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🏨 My Rooms',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final hotelId = _ownerHotelId;
                    if (hotelId == null) return; // guard: should not be reachable, but never crash
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddRoomScreen(
                          hotelId: hotelId,
                        ),
                      ),
                    );
                    if (result == true) _loadRooms();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Room'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your hotel rooms',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Empty state
            if (_rooms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bed_outlined,
                        color: Colors.white24,
                        size: 55,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No rooms yet',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap "Add Room" to list your first room.',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._rooms.map((room) => _buildRoomCard(room)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------
  // ROOM CARD
  // ----------------------------------------------------------------
  Widget _buildRoomCard(Room room) {
    final bool isAvailable = room.isAvailable;
    final Color statusColor = isAvailable ? Colors.green : Colors.orange;
    final String statusLabel =
        isAvailable ? 'Available' : 'Fully Booked';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Room type / bed type
          Text(
            room.bedType.isNotEmpty ? 'Bed: ${room.bedType}' : 'Room #${room.roomNumber}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),

          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              const Icon(Icons.people, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                room.occupancyText,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.bed, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(
                '${room.remainingRooms} left',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const Spacer(),
              Text(
                room.formattedPrice,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditRoom(room),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteRoom(room),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
