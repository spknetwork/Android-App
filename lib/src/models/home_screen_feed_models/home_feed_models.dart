import 'dart:convert';

List<HomeFeed> homeFeedFromJson(String str) => List<HomeFeed>.from(json.decode(str).map((x) => HomeFeed.fromJson(x)));

String homeFeedToJson(List<HomeFeed> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HomeFeed {
  HomeFeed({
    required this.created,
    required this.views,
    required this.owner,
    required this.permlink,
    required this.title,
    required this.duration,
    required this.isNsfwContent,
    required this.tags_v2,
    required this.thumbUrl,
    required this.baseThumbUrl,
    this.ipfs,
  });

  DateTime created;
  int views;
  String owner;
  String permlink;
  String title;
  double duration;
  bool isNsfwContent;
  List<String> tags_v2;
  String? ipfs;
  String thumbUrl;
  String baseThumbUrl;

  factory HomeFeed.fromJson(Map<String, dynamic> json) {
    final created = json['created'] as String?;
    if (created == null) {
      throw UnsupportedError('Invalid data: $json -> "created" is missing');
    }
    final int? views = json['views'] as int?;
    if (views == null) {
      throw UnsupportedError('Invalid data: $json -> "views" is missing');
    }
    final owner = json['owner'] as String?;
    if (owner == null) {
      throw UnsupportedError('Invalid data: $json -> "owner" is missing');
    }
    final permlink = json['permlink'] as String?;
    if (permlink == null) {
      throw UnsupportedError('Invalid data: $json -> "permlink" is missing');
    }
    final title = json['title'] as String?;
    if (title == null) {
      throw UnsupportedError('Invalid data: $json -> "title" is missing');
    }
    final double? duration = json['duration'] as double?;
    if (duration == null) {
      throw UnsupportedError('Invalid data: $json -> "duration" is missing');
    }
    final bool? isNsfwContent = json['isNsfwContent'] as bool?;
    if (isNsfwContent == null) {
      throw UnsupportedError('Invalid data: $json -> "isNsfwContent" is missing');
    }
    final thumbUrl = json['thumbUrl'] as String?;
    if (thumbUrl == null) {
      throw UnsupportedError('Invalid data: $json -> "thumbUrl" is missing');
    }
    final baseThumbUrl = json['baseThumbUrl'] as String?;
    if (baseThumbUrl == null) {
      throw UnsupportedError('Invalid data: $json -> "baseThumbUrl" is missing');
    }
    final ipfs = json['ipfs'] as String?;
    return HomeFeed(
      created: DateTime.parse(created),
      views: views,
      owner: owner,
      permlink: permlink,
      title: title,
      duration: duration,
      isNsfwContent: isNsfwContent,
      tags_v2: json["tags_v2"] == null ? [] : List<String>.from(json["tags_v2"].map((x) => x)),
      ipfs: ipfs,
      thumbUrl: thumbUrl,
      baseThumbUrl: baseThumbUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    "created": created.toIso8601String(),
    "views": views,
    "owner": owner,
    "permlink": permlink,
    "title": title,
    "duration": duration,
    "isNsfwContent": isNsfwContent,
    "tags_v2": List<dynamic>.from(tags_v2.map((x) => x)),
    "thumbUrl": thumbUrl,
    "baseThumbUrl": baseThumbUrl,
    "ipfs": ipfs,
  };
}