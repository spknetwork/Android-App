// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_feed_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeFeed _$HomeFeedFromJson(Map<String, dynamic> json) => HomeFeed(
      author: json['author'] as String,
      permlink: json['permlink'] as String,
      title: json['title'] as String,
      duration: (json['duration'] as num).toDouble(),
      playUrl: json['playUrl'] as String,
      images: HomeFeedImage.fromJson(json['images'] as Map<String, dynamic>),
      created: json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
      views: json['views'] as int?,
      ipfs: json['ipfs'] as String?,
    );

Map<String, dynamic> _$HomeFeedToJson(HomeFeed instance) => <String, dynamic>{
      'created': instance.created?.toIso8601String(),
      'views': instance.views,
      'author': instance.author,
      'permlink': instance.permlink,
      'title': instance.title,
      'duration': instance.duration,
      'ipfs': instance.ipfs,
      'playUrl': instance.playUrl,
      'images': instance.images,
    };
