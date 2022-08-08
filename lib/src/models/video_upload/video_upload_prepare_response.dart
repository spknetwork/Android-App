import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class VideoUploadPrepareResponse {
  final String signedUrl;
  final String filename;
  final double duration;
  final String originalFilename;
  final String status;
  final VideoUploadInfo video;
  final String uploadType;

  VideoUploadPrepareResponse({
    this.signedUrl = "",
    this.filename = "",
    this.duration = 0.0,
    this.originalFilename = "",
    this.status = "",
    required this.video,
    this.uploadType = "",
  });

  factory VideoUploadPrepareResponse.fromJson(Map<String, dynamic>? json) =>
      VideoUploadPrepareResponse(
        signedUrl: asString(json, 'signed_url'),
        filename: asString(json, 'filename'),
        duration: asDouble(json, 'duration'),
        originalFilename: asString(json, 'original_filename'),
        status: asString(json, 'status'),
        video: VideoUploadInfo.fromJson(asMap(json, 'video')),
        uploadType: asString(json, 'upload_type'),
      );

  factory VideoUploadPrepareResponse.fromJsonString(String jsonString) =>
      VideoUploadPrepareResponse.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'signed_url': signedUrl,
        'filename': filename,
        'duration': duration,
        'original_filename': originalFilename,
        'status': status,
        'video': video.toJson(),
        'upload_type': uploadType,
      };
}

class VideoUploadInfo {
  final bool updateSteem;
  final bool lowRc;
  final bool needsBlockchainUpdate;
  final String status;
  final String encodingPriceSteem;
  final bool paid;
  final int encodingProgress;
  final String created;
  final bool is3CJContent;
  final bool isVOD;
  final bool isNsfwContent;
  final bool declineRewards;
  final bool rewardPowerup;
  final String language;
  final String category;
  final bool firstUpload;
  final bool indexed;
  final int views;
  final String hive;
  final bool upvoteEligible;
  final String publishType;
  final String beneficiaries;
  final int votePercent;
  final bool reducedUpvote;
  final bool donations;
  final bool postToHiveBlog;
  final String id;
  final String originalFilename;
  final String permlink;
  final double duration;
  final int size;
  final String owner;
  final String uploadType;
  final int v;
  final String cdn;

  VideoUploadInfo({
    this.updateSteem = false,
    this.lowRc = false,
    this.needsBlockchainUpdate = false,
    this.status = "",
    this.encodingPriceSteem = "",
    this.paid = false,
    this.encodingProgress = 0,
    this.created = "",
    this.is3CJContent = false,
    this.isVOD = false,
    this.isNsfwContent = false,
    this.declineRewards = false,
    this.rewardPowerup = false,
    this.language = "",
    this.category = "",
    this.firstUpload = false,
    this.indexed = false,
    this.views = 0,
    this.hive = "",
    this.upvoteEligible = false,
    this.publishType = "",
    this.beneficiaries = "",
    this.votePercent = 0,
    this.reducedUpvote = false,
    this.donations = false,
    this.postToHiveBlog = false,
    this.id = "",
    this.originalFilename = "",
    this.permlink = "",
    this.duration = 0.0,
    this.size = 0,
    this.owner = "",
    this.uploadType = "",
    this.v = 0,
    this.cdn = "https://ipfs-3speak.b-cdn.net",
  });

  factory VideoUploadInfo.fromJsonString(String jsonString) =>
      VideoUploadInfo.fromJson(json.decode(jsonString));

  factory VideoUploadInfo.fromJson(Map<String, dynamic>? json) =>
      VideoUploadInfo(
        updateSteem: asBool(json, 'updateSteem'),
        lowRc: asBool(json, 'lowRc'),
        needsBlockchainUpdate: asBool(json, 'needsBlockchainUpdate'),
        status: asString(json, 'status'),
        encodingPriceSteem: asString(json, 'encoding_price_steem'),
        paid: asBool(json, 'paid'),
        encodingProgress: asInt(json, 'encodingProgress'),
        created: asString(json, 'created'),
        is3CJContent: asBool(json, 'is3CJContent'),
        isVOD: asBool(json, 'isVOD'),
        isNsfwContent: asBool(json, 'isNsfwContent'),
        declineRewards: asBool(json, 'declineRewards'),
        rewardPowerup: asBool(json, 'rewardPowerup'),
        language: asString(json, 'language'),
        category: asString(json, 'category'),
        firstUpload: asBool(json, 'firstUpload'),
        indexed: asBool(json, 'indexed'),
        views: asInt(json, 'views'),
        hive: asString(json, 'hive'),
        upvoteEligible: asBool(json, 'upvoteEligible'),
        publishType: asString(json, 'publish_type'),
        beneficiaries: asString(json, 'beneficiaries'),
        votePercent: asInt(json, 'votePercent'),
        reducedUpvote: asBool(json, 'reducedUpvote'),
        donations: asBool(json, 'donations'),
        postToHiveBlog: asBool(json, 'postToHiveBlog'),
        id: asString(json, '_id'),
        originalFilename: asString(json, 'originalFilename'),
        permlink: asString(json, 'permlink'),
        duration: asDouble(json, 'duration'),
        size: asInt(json, 'size'),
        owner: asString(json, 'owner'),
        uploadType: asString(json, 'upload_type'),
        v: asInt(json, '__v'),
      );

  Map<String, dynamic> toJson() => {
        'updateSteem': updateSteem,
        'lowRc': lowRc,
        'needsBlockchainUpdate': needsBlockchainUpdate,
        'status': status,
        'encoding_price_steem': encodingPriceSteem,
        'paid': paid,
        'encodingProgress': encodingProgress,
        'created': created,
        'is3CJContent': is3CJContent,
        'isVOD': isVOD,
        'isNsfwContent': isNsfwContent,
        'declineRewards': declineRewards,
        'rewardPowerup': rewardPowerup,
        'language': language,
        'category': category,
        'firstUpload': firstUpload,
        'indexed': indexed,
        'views': views,
        'hive': hive,
        'upvoteEligible': upvoteEligible,
        'publish_type': publishType,
        'beneficiaries': beneficiaries,
        'votePercent': votePercent,
        'reducedUpvote': reducedUpvote,
        'donations': donations,
        'postToHiveBlog': postToHiveBlog,
        '_id': id,
        'originalFilename': originalFilename,
        'permlink': permlink,
        'duration': duration,
        'size': size,
        'owner': owner,
        'upload_type': uploadType,
        '__v': v,
      };
}
