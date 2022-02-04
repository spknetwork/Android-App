// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveComment _$HiveCommentFromJson(Map<String, dynamic> json) => HiveComment(
      author: json['author'] as String,
      permlink: json['permlink'] as String,
      body: json['body'] as String,
      created: DateTime.parse(json['created'] as String),
      depth: json['depth'] as int,
      children: json['children'] as int,
      pendingPayoutValue: json['pendingPayoutValue'] as String,
      parentPermlink: json['parentPermlink'] as String,
      activeVotes: (json['activeVotes'] as List<dynamic>)
          .map((e) => ActiveVote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HiveCommentToJson(HiveComment instance) =>
    <String, dynamic>{
      'author': instance.author,
      'permlink': instance.permlink,
      'body': instance.body,
      'created': instance.created.toIso8601String(),
      'depth': instance.depth,
      'children': instance.children,
      'pendingPayoutValue': instance.pendingPayoutValue,
      'parentPermlink': instance.parentPermlink,
      'activeVotes': instance.activeVotes,
    };
