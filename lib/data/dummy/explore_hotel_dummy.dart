import '../models/user.dart';
import 'video_dummy.dart';
import 'user_dummy.dart';

List<User> trendingHotels = [];

List<User> topPickHotels = [];

void generateExploreHotels() {
  final Map<int, User> hotelMap = {};

  for (final video in videos) {
    if (video.ownerType == "merchant") {
      final hotel = users.firstWhere((user) => user.id == video.ownerId);

      hotelMap[hotel.id] = hotel;
    }
  }

  trendingHotels = hotelMap.values.toList();

  final videoSorted = [...videos];

  videoSorted.sort((a, b) => b.likes.compareTo(a.likes));

  final Map<int, User> topMap = {};

  for (final video in videoSorted) {
    if (video.ownerType == "merchant") {
      final hotel = users.firstWhere((user) => user.id == video.ownerId);

      topMap[hotel.id] = hotel;
    }
  }

  topPickHotels = topMap.values.toList();
}
