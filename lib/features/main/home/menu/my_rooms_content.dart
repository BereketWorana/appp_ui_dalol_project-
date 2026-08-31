import 'package:flutter/material.dart';
import '../../../../data/models/room.dart';
import '../../../../data/services/room_service.dart';
import '../../../main/booking/screens/add_room_screen.dart';
import '../../../main/booking/screens/register_hotel_screen.dart';

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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hotel_outlined,
                  color: Colors.white38,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Hotel Linked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your account isn\'t linked to a hotel yet. '
                'Register your hotel to start managing rooms and bookings.',
                style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterHotelScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.pink.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Register Your Hotel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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
  // UPDATE ROOM STATUS
  // ----------------------------------------------------------------
  Future<void> _showStatusPicker(Room room) async {
    final allowedStatuses = [
      'available',
      'occupied',
      'maintenance',
      'cleaning',
      'reserved',
    ];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Select Operational Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...allowedStatuses.map((st) {
                  final isCurrent = room.status.toLowerCase() == st;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isCurrent
                        ? Colors.pink.shade400.withValues(alpha: 0.15)
                        : null,
                    leading: Icon(
                      _getStatusIcon(st),
                      color: isCurrent ? Colors.pink.shade400 : Colors.white70,
                    ),
                    title: Text(
                      st[0].toUpperCase() + st.substring(1),
                      style: TextStyle(
                        color: isCurrent ? Colors.pink.shade300 : Colors.white,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.check_circle, color: Colors.pink.shade400)
                        : null,
                    onTap: () => Navigator.pop(context, st),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == room.status || !mounted) return;

    try {
      await RoomService.updateRoomStatus(room.id, selected);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Room status updated to "$selected"'),
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
            'Failed to update status: ${msg.isNotEmpty ? msg : "Unknown error"}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Icons.check_circle_outline;
      case 'occupied':
        return Icons.person_outline;
      case 'maintenance':
        return Icons.build_outlined;
      case 'cleaning':
        return Icons.cleaning_services_outlined;
      case 'reserved':
        return Icons.bookmark_border;
      default:
        return Icons.info_outline;
    }
  }

  // ----------------------------------------------------------------
  // TOGGLE ROOM ACTIVE STATUS
  // ----------------------------------------------------------------
  Future<void> _toggleRoomActive(Room room) async {
    try {
      final res = await RoomService.toggleRoomStatus(room.id);
      if (!mounted) return;

      final bool newStatus = !room.isRoomActive;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message']?.toString() ??
                'Room set to ${newStatus ? "Active" : "Inactive"}',
          ),
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
            'Failed to toggle active status: ${msg.isNotEmpty ? msg : "Unknown error"}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ----------------------------------------------------------------
  // ROOM CARD
  // ----------------------------------------------------------------
  Widget _buildRoomCard(Room room) {
    final bool isActive = room.isRoomActive;
    final bool isAvailable = room.isAvailable;
    final Color statusColor = isAvailable ? Colors.green : Colors.orange;
    final String statusLabel = isAvailable ? 'Available' : 'Fully Booked';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF181818) : const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.white10 : Colors.redAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + status badges + active switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (!isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
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
              const SizedBox(width: 4),
              SizedBox(
                height: 24,
                width: 38,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Switch.adaptive(
                    value: isActive,
                    activeColor: Colors.pink.shade400,
                    activeTrackColor: Colors.pink.shade900.withValues(alpha: 0.5),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white10,
                    onChanged: (_) => _toggleRoomActive(room),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Room type / bed type & operational status indicator
          Row(
            children: [
              Text(
                room.bedType.isNotEmpty ? 'Bed: ${room.bedType}' : 'Room #${room.roomNumber}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Status: ${room.status}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
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
                  onPressed: () => _showStatusPicker(room),
                  icon: const Icon(Icons.sync_alt, size: 14),
                  label: Text(
                    room.status.isNotEmpty
                        ? room.status[0].toUpperCase() + room.status.substring(1)
                        : 'Status',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.pink.shade300,
                    side: BorderSide(color: Colors.pink.shade400.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditRoom(room),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteRoom(room),
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
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
