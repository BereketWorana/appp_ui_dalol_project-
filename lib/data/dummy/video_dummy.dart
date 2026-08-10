import '../models/video.dart';

final List<Video> videos = [
  Video(
    id: 1,

    ownerId: 2,

    ownerType: "merchant",

    ownerName: "Skylight Hotel",

    video: "assets/videos/hotel1.mp4",

    thumbnail: "assets/images/r3.jpg",

    title: "Luxury Stay in Addis",

    description:
        "Experience luxury rooms, rooftop dining, and world-class hospitality at Skylight Hotel.",

    likes: 1250,

    comments: 186,

    shares: 74,

    bookmarks: 230,
  ),

  Video(
    id: 2,

    ownerId: 3,

    ownerType: "merchant",

    ownerName: "Sheraton Addis",

    video: "assets/videos/hotel2.mp4",

    thumbnail: "assets/images/r5.jpg",

    title: "Five Star Experience",

    description:
        "Enjoy elegant suites, premium restaurants, relaxing pools, and exceptional service.",

    likes: 2180,

    comments: 295,

    shares: 143,

    bookmarks: 412,
  ),

  Video(
    id: 3,

    ownerId: 2,

    ownerType: "merchant",

    ownerName: "Skylight Hotel",

    video: "assets/videos/hotel3.mp4",

    thumbnail: "assets/images/r3.jpg",

    title: "Conference & Business",

    description:
        "Modern conference halls and executive facilities for business travelers.",

    likes: 980,

    comments: 91,

    shares: 33,

    bookmarks: 121,
  ),

  Video(
    id: 4,

    ownerId: 3,

    ownerType: "merchant",

    ownerName: "Sheraton Addis",

    video: "assets/videos/hotel4.mp4",

    thumbnail: "assets/images/r5.jpg",

    title: "Weekend Escape",

    description:
        "Relax with beautiful gardens, luxury rooms, spa treatments and dining.",

    likes: 1760,

    comments: 224,

    shares: 98,

    bookmarks: 366,
  ),

  Video(
    id: 5,

    ownerId: 4,

    ownerType: "creator",

    ownerName: "Hana Bekele",

    video: "assets/videos/hotel5.mp4",

    thumbnail: "assets/images/r7.jpg",

    title: "Exploring Addis Ababa",

    description:
        "Discover amazing places, food and hidden gems across Addis Ababa.",

    likes: 3415,

    comments: 412,

    shares: 238,

    bookmarks: 695,
  ),

  Video(
    id: 6,

    ownerId: 4,

    ownerType: "creator",

    ownerName: "Hana Bekele",

    video: "assets/videos/hotel6.mp4",

    thumbnail: "assets/images/r7.jpg",

    title: "Hotel Review Tour",

    description: "Tour luxury hotels and share travel tips from Ethiopia.",

    likes: 2986,

    comments: 355,

    shares: 194,

    bookmarks: 541,
  ),
];
