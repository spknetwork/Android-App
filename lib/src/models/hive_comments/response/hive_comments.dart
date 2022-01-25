// To parse this JSON data, do
//
//     final hiveComments = hiveCommentsFromJson(jsonString);

import 'dart:convert';

HiveComments hiveCommentsFromJson(String str) =>
    HiveComments.fromJson(json.decode(str));

String hiveCommentsToJson(HiveComments data) => json.encode(data.toJson());

class HiveComments {
  HiveComments({
    required this.result,
  });

  List<HiveComment> result;

  factory HiveComments.fromJson(Map<String, dynamic> json) => HiveComments(
        result:
            List<HiveComment>.from(json["result"].map((x) => HiveComment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

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

  factory HiveComment.fromJson(Map<String, dynamic> json) => HiveComment(
        author: json["author"],
        permlink: json["permlink"],
        body: json["body"],
        created: DateTime.parse(json["created"]),
        depth: json["depth"],
        children: json["children"],
        pendingPayoutValue: json["pending_payout_value"],
        parentPermlink: json["parent_permlink"],
        activeVotes: List<ActiveVote>.from(
            json["active_votes"].map((x) => ActiveVote.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "author": author,
        "permlink": permlink,
        "body": body,
        "created": created.toIso8601String(),
        "depth": depth,
        "children": children,
        "pending_payout_value": pendingPayoutValue,
        "parent_permlink": parentPermlink,
        "active_votes": List<dynamic>.from(activeVotes.map((x) => x.toJson())),
      };
}

class ActiveVote {
  ActiveVote({
    required this.percent,
  });

  int percent;

  factory ActiveVote.fromJson(Map<String, dynamic> json) => ActiveVote(
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "percent": percent,
      };
}
