import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'active_vote.g.dart';

ActiveVote activeVoteFromJson(String str) =>
    ActiveVote.fromJson(json.decode(str));

@JsonSerializable()
class ActiveVote {
  ActiveVote({
    required this.percent,
  });

  int percent;

  factory ActiveVote.fromJson(Map<String, dynamic> json) =>
      _$ActiveVoteFromJson(json);
}
