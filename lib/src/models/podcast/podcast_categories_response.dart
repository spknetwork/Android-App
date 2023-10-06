import 'dart:convert';

class PodcastCategoriesResponse {
  String? status;
  List<PodcastCategory>? feeds;
  int? count;
  String? description;

  PodcastCategoriesResponse({
    this.status,
    this.feeds,
    this.count,
    this.description,
  });

  factory PodcastCategoriesResponse.fromRawJson(String str) =>
      PodcastCategoriesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PodcastCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      PodcastCategoriesResponse(
        status: json["status"],
        feeds: json["feeds"] == null
            ? []
            : List<PodcastCategory>.from(
                json["feeds"]!.map((x) => PodcastCategory.fromJson(x))),
        count: json["count"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "feeds": feeds == null
            ? []
            : List<dynamic>.from(feeds!.map((x) => x.toJson())),
        "count": count,
        "description": description,
      };
}

class PodcastCategory {
  int? id;
  String? name;

  PodcastCategory({
    this.id,
    this.name,
  });

  factory PodcastCategory.fromRawJson(String str) =>
      PodcastCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PodcastCategory.fromJson(Map<String, dynamic> json) =>
      PodcastCategory(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
