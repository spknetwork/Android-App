import 'dart:convert';

HomeFeedImage homeFeedImageFromJson(String str) => HomeFeedImage.fromJson(json.decode(str));

String homeFeedImageToJson(HomeFeedImage data) => json.encode(data.toJson());

class HomeFeedImage {
  HomeFeedImage({
    required this.thumbnail,
  });
  String thumbnail;

  factory HomeFeedImage.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] as String?;
    if (thumbnail == null) {
      throw UnsupportedError('Invalid data: $json -> "thumbnail" is missing');
    }
    return HomeFeedImage(thumbnail: thumbnail);
  }

  Map<String, dynamic> toJson() => {
    "thumbnail": thumbnail,
  };
}