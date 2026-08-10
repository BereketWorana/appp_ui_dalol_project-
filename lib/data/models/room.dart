class Room {
  final int id;
  final int merchantId;

  final String roomType;
  final String image;
  final String description;

  final int capacity;
  final int pricePerNight;

  final List<String> facilities;

  final bool available;

  Room({
    required this.id,

    required this.merchantId,

    required this.roomType,

    required this.image,

    required this.description,

    required this.capacity,

    required this.pricePerNight,

    required this.facilities,

    required this.available,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json["id"],

      merchantId: json["merchantId"],

      roomType: json["roomType"],

      image: json["image"],

      description: json["description"],

      capacity: json["capacity"],

      pricePerNight: json["pricePerNight"],

      facilities: List<String>.from(json["facilities"]),

      available: json["available"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,

      "merchantId": merchantId,

      "roomType": roomType,

      "image": image,

      "description": description,

      "capacity": capacity,

      "pricePerNight": pricePerNight,

      "facilities": facilities,

      "available": available,
    };
  }
}
