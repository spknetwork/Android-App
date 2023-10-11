
import 'dart:convert';

class TrendingPodCastResponse {
  String? status;
  List<PodCastFeedItem>? feeds;
  List<PodCastFeedItem>? items;
  int? count;
  dynamic max;
  int? since;
  String? description;

  TrendingPodCastResponse({
    this.status,
    this.feeds,
    this.items,
    this.count,
    this.max,
    this.since,
    this.description,
  });

  factory TrendingPodCastResponse.fromRawJson(String str) => TrendingPodCastResponse.fromJson(json.decode(str));

  factory TrendingPodCastResponse.fromJson(Map<String, dynamic> json) => TrendingPodCastResponse(
    status: json["status"],
    feeds: json["feeds"] == null ? [] : List<PodCastFeedItem>.from(json["feeds"]!.map((x) => PodCastFeedItem.fromJson(x))),
    items: json["items"] == null ? [] : List<PodCastFeedItem>.from(json["items"]!.map((x) => PodCastFeedItem.fromJson(x))),
    count: json["count"],
    max: json["max"],
    since: json["since"],
    description: json["description"],
  );
}

class PodCastFeedItem {
  int? id;
  String? url;
  String? title;
  String? description;
  String? author;
  String? image;
  String? feedImage;
  String? artwork;
  int? newestItemPublishTime;
  int? itunesId;
  int? trendScore;
  String? language;

  String? get networkImage {
    if (image != null && image!.isNotEmpty) {
      return image;
    }
    if (feedImage != null && feedImage!.isNotEmpty) {
      return feedImage;
    }
    return null;
  }

  PodCastFeedItem({
    this.id,
    this.url,
    this.title,
    this.description,
    this.author,
    this.image,
    this.feedImage,
    this.artwork,
    this.newestItemPublishTime,
    this.itunesId,
    this.trendScore,
    this.language,
    // this.categories,
  });

  factory PodCastFeedItem.fromRawJson(String str) => PodCastFeedItem.fromJson(json.decode(str));

  // String toRawJson() => json.encode(toJson());

  factory PodCastFeedItem.fromJson(Map<String, dynamic> json) => PodCastFeedItem(
    id: json["id"],
    url: json["url"],
    title: json["title"],
    description: json["description"],
    author: json["author"],
    image: json["image"],
    feedImage: json["feedImage"],
    artwork: json["artwork"],
    newestItemPublishTime: json["newestItemPublishTime"],
    itunesId: json["itunesId"],
    trendScore: json["trendScore"],
    language: json["language"],
    // categories: json["categories"] != null ? Map.from(json["categories"]!).map((k, v) => MapEntry<String, String>(k, v)) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "title": title,
    "description": description,
    "author": author,
    "image": image,
    "feedImage": feedImage,
    "artwork": artwork,
    "newestItemPublishTime": newestItemPublishTime,
    "itunesId": itunesId,
    "trendScore": trendScore,
    "language": language,
    // "categories": Map.from(categories!).map((k, v) => MapEntry<String, dynamic>(k, v)),
  };
}
