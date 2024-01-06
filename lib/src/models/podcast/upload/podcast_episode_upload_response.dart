import 'dart:convert';

class PodcastEpisodeUploadResponse {
  String id;
  String permlink;
  String title;
  String description;
  String community;
  String thumbnail;
  String enclosureUrl;
  bool firstUpload;

  PodcastEpisodeUploadResponse({
    required this.id,
    required this.permlink,
    required this.title,
    required this.description,
    required this.community,
    required this.thumbnail,
    required this.enclosureUrl,
    required this.firstUpload,
  });

  static PodcastEpisodeUploadResponse podcastEpisodeUploadResponseFromJson(
          String str) =>
      PodcastEpisodeUploadResponse.fromJson(json.decode(str));

  static String podcastEpisodeUploadResponseToJson(
          PodcastEpisodeUploadResponse data) =>
      json.encode(data.toJson());

  factory PodcastEpisodeUploadResponse.fromJson(Map<String, dynamic> json) =>
      PodcastEpisodeUploadResponse(
        id: json["id"],
        permlink: json["permlink"],
        title: json["title"],
        description: json["description"],
        community: json["community"],
        thumbnail: json["thumbnail"],
        enclosureUrl: json["enclosureUrl"],
        firstUpload: json["firstUpload"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "permlink": permlink,
        "title": title,
        "description": description,
        "community": community,
        "thumbnail": thumbnail,
        "enclosureUrl": enclosureUrl,
        "firstUpload": firstUpload,
      };
}
