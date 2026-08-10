import '../models/room.dart';

final List<Room> rooms = [
  Room(
    id: 1,

    merchantId: 2,

    roomType: "Deluxe Room",

    image: "assets/rooms/room1.jpg",

    description:
        "Elegant deluxe room with modern furniture, city view and premium facilities.",

    capacity: 2,

    pricePerNight: 4500,

    facilities: [
      "Free WiFi",

      "Breakfast Included",

      "Air Conditioning",

      "Smart TV",
    ],

    available: true,
  ),

  Room(
    id: 2,

    merchantId: 2,

    roomType: "Executive Suite",

    image: "assets/rooms/room2.jpg",

    description:
        "Spacious executive suite designed for business and luxury travelers.",

    capacity: 4,

    pricePerNight: 7000,

    facilities: ["Free WiFi", "Mini Bar", "Living Area"],

    available: true,
  ),

  Room(
    id: 3,

    merchantId: 3,

    roomType: "Luxury Suite",

    image: "assets/rooms/room3.jpg",

    description:
        "Five-star luxury suite with premium interior and exclusive services.",

    capacity: 3,

    pricePerNight: 9000,

    facilities: ["Swimming Pool", "Restaurant Access", "Room Service"],

    available: true,
  ),

  Room(
    id: 4,

    merchantId: 3,

    roomType: "Family Suite",

    image: "assets/rooms/room4.jpg",

    description:
        "Large family room suitable for groups with comfortable facilities.",

    capacity: 5,

    pricePerNight: 12000,

    facilities: ["Free WiFi", "Extra Beds", "Kitchen Area"],

    available: true,
  ),
];
