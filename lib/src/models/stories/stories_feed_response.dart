import 'dart:convert';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/safe_convert.dart';

class StoriesFeedResponseItem {
  final bool fromMobile;
  final bool isReel;
  final String id;
  final String filename;
  final String originalFilename;
  final String permlink;
  final double duration;
  final int size;
  final String owner;
  final String uploadType;
  final int v;
  final String description;
  final String tags;
  final String thumbnail;
  final String title;
  final String thumbUrl;
  final String baseThumbUrl;
  final String playUrl;
  final String publishData;
  final String localFilename;
  final String jobId;
  final String created;
  final int views;

  String getVideoUrl(HiveUserData data) {
    if (playUrl.contains('ipfs')) {
      // example
      // https://ipfs-3speak.b-cdn.net/ipfs/QmTRDJcgtt66pxs3ZnQCdRw57b69NS2TQvF4yHwaux5grT/manifest.m3u8
      // https://ipfs-3speak.b-cdn.net/ipfs/QmTRDJcgtt66pxs3ZnQCdRw57b69NS2TQvF4yHwaux5grT/480p/index.m3u8
      return playUrl.replaceAll('manifest', '${data.resolution}/index');
    } else {
      // example
      // https://threespeakvideo.b-cdn.net/chjwguvd/default.m3u8
      // https://threespeakvideo.b-cdn.net/chjwguvd/480p.m3u8
      return playUrl.replaceAll('default', '${data.resolution}');
    }
  }

  StoriesFeedResponseItem({
    this.fromMobile = false,
    this.isReel = false,
    this.id = "",
    this.filename = "",
    this.originalFilename = "",
    this.permlink = "",
    this.duration = 0.0,
    this.size = 0,
    this.owner = "",
    this.uploadType = "",
    this.v = 0,
    this.description = "",
    this.tags = "",
    this.thumbnail = "",
    this.title = "",
    this.thumbUrl = "",
    this.baseThumbUrl = "",
    this.playUrl = "",
    this.publishData = "",
    this.localFilename = "",
    this.jobId = "",
    this.created = "",
    this.views = 0,
  });

  List<StoriesFeedResponseItem> fromJsonString(String jsonString, String type) {
    if (type == 'feed') {
      final jsonList = json.decode(jsonString) as List;
      return jsonList.map((e) => StoriesFeedResponseItem.fromJson(e)).toList();
    } else if (type == 'trends') {
      final jsonObj = json.decode(jsonString) as Map;
      final jsonList = jsonObj['trends'] as List;
      return jsonList.map((e) => StoriesFeedResponseItem.fromJson(e)).toList();
    } else {
      final jsonObj = json.decode(jsonString) as Map;
      final jsonList = jsonObj['recommended'] as List;
      return jsonList.map((e) => StoriesFeedResponseItem.fromJson(e)).toList();
    }
  }

  factory StoriesFeedResponseItem.fromJson(Map<String, dynamic>? json) =>
      StoriesFeedResponseItem(
        fromMobile: asBool(json, 'fromMobile'),
        isReel: asBool(json, 'isReel'),
        id: asString(json, '_id'),
        filename: asString(json, 'filename'),
        originalFilename: asString(json, 'originalFilename'),
        permlink: asString(json, 'permlink'),
        duration: asDouble(json, 'duration'),
        size: asInt(json, 'size'),
        owner: asString(json, 'owner'),
        uploadType: asString(json, 'upload_type'),
        v: asInt(json, '__v'),
        description: asString(json, 'description'),
        tags: asString(json, 'tags'),
        thumbnail: asString(json, 'thumbnail'),
        title: asString(json, 'title'),
        thumbUrl: asString(json, 'thumbUrl'),
        baseThumbUrl: asString(json, 'baseThumbUrl'),
        playUrl: asString(json, 'playUrl'),
        publishData: asString(json, 'publish_data'),
        localFilename: asString(json, 'local_filename'),
        jobId: asString(json, 'job_id'),
        created: asString(json, 'created'),
        views: asInt(json, 'views'),
      );
}
