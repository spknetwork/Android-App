// To parse this JSON data, do
//
//     final hiveComments = hiveCommentsFromJson(jsonString);

import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'hive_comment.dart';
part 'hive_comments.g.dart';

HiveComments hiveCommentsFromJson(String str) =>
    HiveComments.fromJson(json.decode(str));

@JsonSerializable()
class HiveComments {
  HiveComments({
    required this.result,
  });

  List<HiveComment> result;

  factory HiveComments.fromJson(Map<String, dynamic> json) => _$HiveCommentsFromJson(json);
}
