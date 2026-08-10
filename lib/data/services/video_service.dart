import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/video.dart';

class VideoService {
  static Future<List<Video>> getVideos() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/videos.json',
    );

    final List<dynamic> data = json.decode(jsonString);

    return data.map((item) => Video.fromJson(item)).toList();
  }
}
