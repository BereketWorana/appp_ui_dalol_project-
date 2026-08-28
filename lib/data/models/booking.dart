class Booking {
  final int id;
  final String bookingReference;
  final int userId;
  final int hotelId;
  final int roomId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final int adults;
  final int children;
  final int roomsCount;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? room;
  final Map<String, dynamic>? hotel;

  Booking({
    required this.id,
    required this.bookingReference,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    required this.adults,
    required this.children,
    required this.roomsCount,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    this.room,
    this.hotel,
  });

  // ============================================================
  // CONVERT JSON TO BOOKING OBJECT
  // ============================================================

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id'].toString()) ?? 0,
      bookingReference: json['booking_reference'] ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      hotelId: int.tryParse(json['hotel_id']?.toString() ?? '0') ?? 0,
      roomId: int.tryParse(json['room_id']?.toString() ?? '0') ?? 0,
      checkInDate: DateTime.tryParse(json['check_in_date'] ?? '') ?? DateTime.now(),
      checkOutDate: DateTime.tryParse(json['check_out_date'] ?? '') ?? DateTime.now(),
      nights: int.tryParse(json['nights']?.toString() ?? '0') ?? 0,
      adults: int.tryParse(json['adults']?.toString() ?? '1') ?? 1,
      children: int.tryParse(json['children']?.toString() ?? '0') ?? 0,
      roomsCount: int.tryParse(json['rooms_count']?.toString() ?? '1') ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      guestName: json['guest_name'] ?? '',
      guestEmail: json['guest_email'] ?? '',
      guestPhone: json['guest_phone'] ?? '',
      specialRequests: json['special_requests'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      room: json['room'],
      hotel: json['hotel'],
    );
  }

  // ============================================================
  // CONVERT BOOKING TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_reference': bookingReference,
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'nights': nights,
      'adults': adults,
      'children': children,
      'rooms_count': roomsCount,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'guest_name': guestName,
      'guest_email': guestEmail,
      'guest_phone': guestPhone,
      'special_requests': specialRequests,
    };
  }

  // ============================================================
  // CONVENIENCE GETTERS
  // ============================================================

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isPaid => paymentStatus == 'paid';
}
