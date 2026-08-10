class Booking {
  final int id;
  final int consumerId;
  final int merchantId;

  final String roomType;
  final String checkIn;
  final String checkOut;

  final int guests;
  final int totalPrice;

  final String status;
  final String bookingDate;

  Booking({
    required this.id,
    required this.consumerId,
    required this.merchantId,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.bookingDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json["id"],
      consumerId: json["consumerId"],
      merchantId: json["merchantId"],
      roomType: json["roomType"],
      checkIn: json["checkIn"],
      checkOut: json["checkOut"],
      guests: json["guests"],
      totalPrice: json["totalPrice"],
      status: json["status"],
      bookingDate: json["bookingDate"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "consumerId": consumerId,
      "merchantId": merchantId,
      "roomType": roomType,
      "checkIn": checkIn,
      "checkOut": checkOut,
      "guests": guests,
      "totalPrice": totalPrice,
      "status": status,
      "bookingDate": bookingDate,
    };
  }
}
