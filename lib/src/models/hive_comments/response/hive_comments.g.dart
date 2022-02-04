// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_comments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HiveComments _$HiveCommentsFromJson(Map<String, dynamic> json) => HiveComments(
      result: (json['result'] as List<dynamic>)
          .map((e) => HiveComment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HiveCommentsToJson(HiveComments instance) =>
    <String, dynamic>{
      'result': instance.result,
    };
