import '../models/post.dart';

// ============================================================
// MOCK FEED DATA
// ============================================================
//
// Used when:
//   1. The real API returns an empty list (backend not seeded yet)
//   2. Running in offline / demo mode
//
// HOW TO SWAP TO REAL DATA:
//   In FeedService.getFeed(), remove the fallback block:
//     if (posts.isEmpty) { return _mockPosts; }
//
// All media references use local assets that are already bundled
// in the app (see pubspec.yaml for asset declarations).

final List<Post> mockPosts = [
  Post(
    id: 1,
    ownerId: 2,
    ownerName: 'Skylight Hotel',
    ownerAvatar: 'assets/images/r3.jpg',
    ownerRole: 'merchant',
    ownerUsername: '@skylighthotel',
    hotelId: 10,
    mediaUrl: 'assets/videos/hotel1.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r3.jpg',
    caption:
        'Experience luxury rooms, rooftop dining, and world-class hospitality at Skylight Hotel.',
    hashtags: ['luxury', 'addisababa', 'hotel', 'Ethiopia'],
    location: 'Addis Ababa, Ethiopia',
    price: 3800,
    rating: 4.8,
    likes: 1250,
    comments: 186,
    shares: 74,
    bookmarks: 230,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),

  Post(
    id: 2,
    ownerId: 3,
    ownerName: 'Sheraton Addis',
    ownerAvatar: 'assets/images/r5.jpg',
    ownerRole: 'merchant',
    ownerUsername: '@sheratonaddis',
    hotelId: 11,
    mediaUrl: 'assets/videos/hotel2.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r5.jpg',
    caption:
        'Enjoy elegant suites, premium restaurants, relaxing pools, and exceptional service.',
    hashtags: ['fivestar', 'luxury', 'Sheraton', 'addis'],
    location: 'Taitu Street, Addis Ababa',
    price: 7500,
    rating: 4.9,
    likes: 2180,
    comments: 295,
    shares: 143,
    bookmarks: 412,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),

  Post(
    id: 3,
    ownerId: 4,
    ownerName: 'Hana Bekele',
    ownerAvatar: 'assets/images/r7.jpg',
    ownerRole: 'creator',
    ownerUsername: '@hanabekele',
    hotelId: 10, // tagged hotel
    mediaUrl: 'assets/videos/hotel3.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r7.jpg',
    caption:
        'I stayed here for 3 nights and WOW — this is the best hotel in Addis! 🔥 Highly recommend.',
    hashtags: ['travel', 'Ethiopia', 'hotelreview', 'addisababa'],
    location: 'Addis Ababa, Ethiopia',
    price: 3800,
    rating: 4.7,
    likes: 3415,
    comments: 412,
    shares: 238,
    bookmarks: 695,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(hours: 10)),
  ),

  Post(
    id: 4,
    ownerId: 2,
    ownerName: 'Skylight Hotel',
    ownerAvatar: 'assets/images/r3.jpg',
    ownerRole: 'merchant',
    ownerUsername: '@skylighthotel',
    hotelId: 10,
    mediaUrl: 'assets/videos/hotel4.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r3.jpg',
    caption:
        'Modern conference halls and executive facilities for business travelers.',
    hashtags: ['business', 'conference', 'corporate', 'addis'],
    location: 'Addis Ababa, Ethiopia',
    price: 4200,
    rating: 4.8,
    likes: 980,
    comments: 91,
    shares: 33,
    bookmarks: 121,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),

  Post(
    id: 5,
    ownerId: 3,
    ownerName: 'Sheraton Addis',
    ownerAvatar: 'assets/images/r5.jpg',
    ownerRole: 'merchant',
    ownerUsername: '@sheratonaddis',
    hotelId: 11,
    mediaUrl: 'assets/videos/hotel5.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r5.jpg',
    caption:
        'Relax with beautiful gardens, luxury rooms, spa treatments and dining experiences.',
    hashtags: ['spa', 'relax', 'luxury', 'weekend'],
    location: 'Taitu Street, Addis Ababa',
    price: 7500,
    rating: 4.9,
    likes: 1760,
    comments: 224,
    shares: 98,
    bookmarks: 366,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),

  Post(
    id: 6,
    ownerId: 4,
    ownerName: 'Hana Bekele',
    ownerAvatar: 'assets/images/r7.jpg',
    ownerRole: 'creator',
    ownerUsername: '@hanabekele',
    hotelId: null, // pure travel content, no hotel tagged
    mediaUrl: 'assets/videos/hotel6.mp4',
    mediaType: 'video',
    thumbnail: 'assets/images/r7.jpg',
    caption:
        'Tour luxury hotels and share travel tips from Ethiopia. Follow for daily travel content! 🌍',
    hashtags: ['travel', 'Ethiopia', 'explore', 'travelblogger'],
    location: 'Ethiopia',
    price: null,
    rating: null,
    likes: 2986,
    comments: 355,
    shares: 194,
    bookmarks: 541,
    isLiked: false,
    isFollowing: false,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
