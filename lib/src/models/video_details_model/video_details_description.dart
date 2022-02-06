import 'dart:convert';
import 'package:acela/src/utils/safe_convert.dart';

VideoDetailsDescription videoDetailsDescriptionFromJson(String str) =>
    VideoDetailsDescription.fromJson(json.decode(str));

String videoDetailsDescriptionToJson(VideoDetailsDescription data) =>
    json.encode(data.toJson());

class VideoDetailsDescription {
  VideoDetailsDescription({
    required this.description,
  });

  String description;

  factory VideoDetailsDescription.fromJson(Map<String, dynamic>? json) =>
      VideoDetailsDescription(
        description: asString(json, 'description'),
      );

  Map<String, dynamic> toJson() => {
    'description': description
  };
}
