import '../models/user.dart';

import 'user_dummy.dart';
import 'video_dummy.dart';

List<User> getTrendingHotels() {
  Map<int, User> hotelMap = {};

  for (final video in videos) {
    if (video.ownerType == "merchant") {
      final hotel = users.firstWhere((user) => user.id == video.ownerId);

      hotelMap[hotel.id] = hotel;
    }
  }

  return hotelMap.values.toList();
}

List<User> getTopPickHotels() {
  final sortedVideos = [...videos];

  sortedVideos.sort((a, b) => b.likes.compareTo(a.likes));

  Map<int, User> hotelMap = {};

  for (final video in sortedVideos) {
    if (video.ownerType == "merchant") {
      final hotel = users.firstWhere((user) => user.id == video.ownerId);

      hotelMap[hotel.id] = hotel;
    }
  }

  return hotelMap.values.toList();
}
