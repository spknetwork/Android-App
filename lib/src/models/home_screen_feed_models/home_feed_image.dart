import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
part 'home_feed_image.g.dart';

HomeFeedImage homeFeedImageFromJson(String str) => HomeFeedImage.fromJson(json.decode(str));

@JsonSerializable()
class HomeFeedImage {
  HomeFeedImage({
    required this.thumbnail,
  });
  String thumbnail;

  factory HomeFeedImage.fromJson(Map<String, dynamic> json) => _$HomeFeedImageFromJson(json);
}