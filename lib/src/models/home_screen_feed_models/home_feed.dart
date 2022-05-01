import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

// final jsonList = json.decode(jsonStr) as List;
// final list = jsonList.map((e) => HomeFeedItem.fromJson(e)).toList();

List<HomeFeedItem> homeFeedItemFromString(String string) {
  final jsonList = json.decode(string) as List;
  final list = jsonList.map((e) => HomeFeedItem.fromJson(e)).toList();
  return list;
}

class PayoutInfo {
  double? payout;
  int? upVotes;
  int? downVotes;
  PayoutInfo({
    required this.payout,
    required this.upVotes,
    required this.downVotes,
  });
}

class HomeFeedItem {
  final String created;
  final String language;
  final int views;
  final String author;
  final String permlink;
  final String title;
  final double duration;
  final bool isNsfw;
  final List<String> tags;
  final bool isIpfs;
  final String playUrl;
  final String ipfs;
  final HomeFeedItemImage images;

  HomeFeedItem({
    this.created = "",
    this.language = "",
    this.views = 0,
    this.author = "",
    this.permlink = "",
    this.title = "",
    this.duration = 0.0,
    this.isNsfw = false,
    required this.tags,
    this.isIpfs = false,
    this.playUrl = "",
    this.ipfs = "",
    required this.images,
  });

  DateTime? get createdAt {
    return DateTime.tryParse(created);
  }

  factory HomeFeedItem.fromJson(Map<String, dynamic>? json) => HomeFeedItem(
        created: asString(json, 'created'),
        language: asString(json, 'language'),
        views: asInt(json, 'views'),
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        title: asString(json, 'title'),
        duration: asDouble(json, 'duration'),
        isNsfw: asBool(json, 'isNsfw'),
        tags: asList(json, 'tags').map((e) => e.toString()).toList(),
        isIpfs: asBool(json, 'isIpfs'),
        playUrl: asString(json, 'playUrl'),
        ipfs: asString(json, 'ipfs'),
        images: HomeFeedItemImage.fromJson(asMap(json, 'images')),
      );

  Map<String, dynamic> toJson() => {
        'created': created,
        'language': language,
        'views': views,
        'author': author,
        'permlink': permlink,
        'title': title,
        'duration': duration,
        'isNsfw': isNsfw,
        'tags': tags.map((e) => e),
        'isIpfs': isIpfs,
        'playUrl': playUrl,
        'ipfs': ipfs,
        'images': images.toJson(),
      };
}

class HomeFeedItemImage {
  final String ipfsThumbnail;
  final String thumbnail;

  HomeFeedItemImage({
    this.ipfsThumbnail = "",
    this.thumbnail = "",
  });

  factory HomeFeedItemImage.fromJson(Map<String, dynamic>? json) =>
      HomeFeedItemImage(
        ipfsThumbnail: asString(json, 'ipfs_thumbnail'),
        thumbnail: asString(json, 'thumbnail'),
      );

  Map<String, dynamic> toJson() => {
        'ipfs_thumbnail': ipfsThumbnail,
        'thumbnail': thumbnail,
      };
}
