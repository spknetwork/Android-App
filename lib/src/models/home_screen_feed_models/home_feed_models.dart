import 'dart:convert';

import 'package:acela/src/models/home_screen_feed_models/home_feed_image.dart';

List<HomeFeed> homeFeedFromJson(String str) => List<HomeFeed>.from(json.decode(str).map((x) => HomeFeed.fromJson(x)));

String homeFeedToJson(List<HomeFeed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HomeFeed {
  HomeFeed({
    required this.created,
    required this.views,
    required this.author,
    required this.permlink,
    required this.title,
    required this.duration,
    required this.playUrl,
    required this.images,
    this.ipfs,
  });

  DateTime created;
  int views;
  String author;
  String permlink;
  String title;
  double duration;
  String? ipfs;
  String playUrl;
  HomeFeedImage images;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    final created = json['created'] as String?;
    if (created == null) {
      throw UnsupportedError('Invalid data: $json -> "created" is missing');
    }
    final int? views = json['views'] as int?;
    if (views == null) {
      throw UnsupportedError('Invalid data: $json -> "views" is missing');
    }
    final author = json['author'] as String?;
    if (author == null) {
      throw UnsupportedError('Invalid data: $json -> "author" is missing');
    }
    final permlink = json['permlink'] as String?;
    if (permlink == null) {
      throw UnsupportedError('Invalid data: $json -> "permlink" is missing');
    }
    final title = json['title'] as String?;
    if (title == null) {
      throw UnsupportedError('Invalid data: $json -> "title" is missing');
    }
    final double? duration = double.parse(json['duration'].toString());
    if (duration == null) {
      throw UnsupportedError('Invalid data: $json -> "duration" is missing');
    }
    final playUrl = json['playUrl'] as String?;
    if (playUrl == null) {
      throw UnsupportedError('Invalid data: $json -> "playUrl" is missing');
    }
    final images = json['images'] as Map<String, dynamic>?;
    if (images == null) {
      throw UnsupportedError('Invalid data: $json -> "images" is missing');
    }
    final ipfs = json['ipfs'] as String?;
    return HomeFeed(
      created: DateTime.parse(created),
      views: views,
      author: author,
      permlink: permlink,
      title: title,
      duration: duration,
      ipfs: ipfs,
      playUrl: playUrl,
      images: HomeFeedImage.fromJson(images),
    );
  }

  Map<String, dynamic> toJson() => {
    "created": created.toIso8601String(),
    "views": views,
    "author": author,
    "permlink": permlink,
    "title": title,
    "duration": duration,
    "playUrl": playUrl,
    "images": homeFeedImageToJson(images),
    "ipfs": ipfs,
  };
}