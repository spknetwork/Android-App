import 'dart:convert';
import 'active_vote.dart';
import 'package:json_annotation/json_annotation.dart';
part 'hive_comment.g.dart';

HiveComment hiveCommentFromJson(String str) =>
    HiveComment.fromJson(json.decode(str));

@JsonSerializable()
class HiveComment {
  HiveComment({
    required this.author,
    required this.permlink,
    required this.body,
    required this.created,
    required this.depth,
    required this.children,
    required this.pendingPayoutValue,
    required this.parentPermlink,
    required this.activeVotes,
  });

  String author;
  String permlink;
  String body;
  DateTime created;
  int depth;
  int children;
  String pendingPayoutValue;
  String parentPermlink;
  List<ActiveVote> activeVotes;

  factory HiveComment.fromJson(Map<String, dynamic> json) => _$HiveCommentFromJson(json);
}