import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

List<VideoRecommendationItem> videoRecommendationItemsFromJson(String str) {
  final jsonList = json.decode(str) as List;
  return jsonList.map((e) => VideoRecommendationItem.fromJson(e)).toList();
}

class VideoRecommendationItem {
  // https://img.3speakcontent.co/asxmrbot/poster.png
  final String image;
  // I am alive challenge day 131 // crossing the bridge
  final String title;
  // asxmrbot
  final String mediaid;
  // dobro2020
  final String owner;

  double? payout;
  int? upVotes;
  int? downVotes;

  VideoRecommendationItem({
    this.image = "",
    this.title = "",
    this.mediaid = "",
    this.owner = "",
  });

  factory VideoRecommendationItem.fromJson(Map<String, dynamic>? json) =>
      VideoRecommendationItem(
        image: asString(json, 'image'),
        title: asString(json, 'title'),
        mediaid: asString(json, 'mediaid'),
        owner: asString(json, 'owner'),
      );

  Map<String, dynamic> toJson() => {
        'image': image,
        'title': title,
        'mediaid': mediaid,
        'owner': owner,
      };
}
