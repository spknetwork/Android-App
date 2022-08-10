import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

List<VideoDetails> videoItemsFromString(String string) {
  final jsonList = json.decode(string) as List;
  final list = jsonList.map((e) => VideoDetails.fromJson(e)).toList();
  return list;
}

class VideoDetails {
  final String created;
  final bool paid;
  final int views;
  final List<String> tagsV2;
  final String id;
  final String community;
  final String owner;
  final String baseThumbUrl;
  final bool steemPosted;
  final String status;
  final String playUrl;

  final String thumbnail;

  final String thumbUrl;
  final String video_v2;
  final String description;
  final String title;
  final String tags;
  final String permlink;
  final double duration;
  final int size;
  final String originalFilename;
  final bool firstUpload;
  final String beneficiaries;

  VideoDetails({
    this.created = "",
    this.paid = false,
    this.views = 0,
    required this.tagsV2,
    this.id = "",
    this.community = "",
    this.permlink = "",
    this.duration = 0.0,
    this.size = 0,
    this.owner = "",
    this.description = "",
    this.thumbnail = "",
    this.title = "",
    this.thumbUrl = "",
    this.baseThumbUrl = "",
    this.playUrl = "",
    this.steemPosted = false,
    this.status = "",
    required this.video_v2,
    required this.tags,
    required this.originalFilename,
    required this.firstUpload,
    required this.beneficiaries,
  });

  factory VideoDetails.fromJsonString(String jsonString) =>
      VideoDetails.fromJson(json.decode(jsonString));

  List<String> get benes {
    if (beneficiaries == "[]") {
      return ["sagarkothari88", "100"];
    } else {
      try {
        var array = json.decode(beneficiaries) as List<dynamic>;
        var list = array.map((e) => e['account']).toList();
        var amounts = array.map((e) => e['weight']).toList();
        if (!list.contains('sagarkothari88')) {
          list.add('sagarkothari88');
          amounts.add('100');
        }
        return [list.join(","), amounts.join(",")];
      } catch (e) {
        return ["sagarkothari88", "100"];
      }
    }
  }

  factory VideoDetails.fromJson(Map<String, dynamic>? json) => VideoDetails(
        created: asString(json, 'created'),
        paid: asBool(json, 'paid'),
        views: asInt(json, 'views'),
        tagsV2: asList(json, 'tags_v2').map((e) => e.toString()).toList(),
        id: asString(json, '_id'),
        community: asString(json, 'community'),
        permlink: asString(json, 'permlink'),
        duration: asDouble(json, 'duration'),
        size: asInt(json, 'size'),
        owner: asString(json, 'owner'),
        description: asString(json, 'description'),
        thumbnail: asString(json, 'thumbnail'),
        title: asString(json, 'title'),
        thumbUrl: asString(json, 'thumbUrl'),
        baseThumbUrl: asString(json, 'baseThumbUrl'),
        playUrl: asString(json, 'playUrl'),
        steemPosted: asBool(json, 'steemPosted'),
        status: asString(json, 'status'),
        tags: asString(json, 'tags'),
        video_v2: asString(json, 'video_v2'),
        originalFilename: asString(json, 'originalFilename'),
        firstUpload: asBool(json, 'firstUpload'),
        beneficiaries: asString(json, 'beneficiaries'),
      );

  String toJsonString() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'created': created,
        'paid': paid,
        'views': views,
        'tags_v2': tagsV2.map((e) => e),
        '_id': id,
        'community': community,
        'permlink': permlink,
        'duration': duration,
        'size': size,
        'owner': owner,
        'description': description,
        'thumbnail': thumbnail,
        'title': title,
        'thumbUrl': thumbUrl,
        'baseThumbUrl': baseThumbUrl,
        'playUrl': playUrl,
        'steemPosted': steemPosted,
        'status': status,
      };
}
