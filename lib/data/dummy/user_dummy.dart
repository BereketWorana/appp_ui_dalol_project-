import '../models/user.dart';

final List<User> users = [
  User(
    id: 1,
    fullName: "Tesfaye Zeleke",
    phone: "+251911111111",
    email: "tesfayezeleke@gmail.com",
    password: "123456",
    role: "consumer",
    profileImage: "assets/images/r1.jpg",
    coverImage: "assets/images/r2.jpg",
  ),

  User(
    id: 2,
    fullName: "Skylight Hotel",
    phone: "+251922222222",
    email: "skylighthotel@gmail.com",
    password: "123456",
    role: "merchant",
    profileImage: "assets/images/r3.jpg",
    coverImage: "assets/images/r4.jpg",
  ),

  User(
    id: 3,
    fullName: "Sheraton Addis",
    phone: "+251933333333",
    email: "sheratonaddis@gmail.com",
    password: "123456",
    role: "merchant",
    profileImage: "assets/images/r5.jpg",
    coverImage: "assets/images/r6.jpg",
  ),

  User(
    id: 4,
    fullName: "Hana Bekele",
    phone: "+251944444444",
    email: "hanabekele@gmail.com",
    password: "123456",
    role: "creator",
    profileImage: "assets/images/r7.jpg",
    coverImage: "assets/images/r8.jpg",
  ),
];
