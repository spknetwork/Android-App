import 'dart:convert';

VideoDetailsDescription videoDetailsDescriptionFromJson(String str) => VideoDetailsDescription.fromJson(json.decode(str));

String videoDetailsDescriptionToJson(VideoDetailsDescription data) => json.encode(data.toJson());

class VideoDetailsDescription {
  VideoDetailsDescription({
    required this.description,
  });

  String description;

  factory VideoDetailsDescription.fromJson(Map<String, dynamic> json) => VideoDetailsDescription(
    description: json["description"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "description": description,
  };
}