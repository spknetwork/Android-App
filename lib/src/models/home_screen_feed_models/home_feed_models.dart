import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_image.dart';
part 'home_feed_models.g.dart';

List<HomeFeed> homeFeedFromJson(String str) => List<HomeFeed>.from(json.decode(str).map((x) => HomeFeed.fromJson(x)));

@JsonSerializable()
class HomeFeed {
  HomeFeed({
    required this.author,
    required this.permlink,
    required this.title,
    required this.duration,
    required this.playUrl,
    required this.images,
    this.created,
    this.views,
    this.ipfs,
  });

  DateTime? created;
  int? views;
  String author;
  String permlink;
  String title;
  double duration;
  String? ipfs;
  String playUrl;
  HomeFeedImage images;

  factory HomeFeed.fromJson(Map<String, dynamic> json) => _$HomeFeedFromJson(json);
}