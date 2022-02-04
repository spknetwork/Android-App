import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'video_details_description.g.dart';

VideoDetailsDescription videoDetailsDescriptionFromJson(String str) =>
    VideoDetailsDescription.fromJson(json.decode(str));

String videoDetailsDescriptionToJson(VideoDetailsDescription data) =>
    json.encode(data.toJson());

@JsonSerializable()
class VideoDetailsDescription {
  VideoDetailsDescription({
    required this.description,
  });

  String description;

  factory VideoDetailsDescription.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailsDescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$VideoDetailsDescriptionToJson(this);
}
