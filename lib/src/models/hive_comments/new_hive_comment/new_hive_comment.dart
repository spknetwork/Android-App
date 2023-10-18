// To parse this JSON data, do
//
//     final postFeedModel = postFeedModelFromJson(jsonString);

import 'dart:convert';

class HiveCommentData {
  final Data data;

  HiveCommentData({
    required this.data,
  });

  factory HiveCommentData.fromRawJson(String str) =>
      HiveCommentData.fromJson(json.decode(str));

  String toRawJson(HiveCommentData data) => json.encode(data.toJson());

  factory HiveCommentData.fromJson(Map<String, dynamic> json) =>
      HiveCommentData(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  final SocialPost socialPost;

  Data({
    required this.socialPost,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        socialPost: SocialPost.fromJson(json["socialPost"]),
      );

  Map<String, dynamic> toJson() => {
        "socialPost": socialPost.toJson(),
      };
}

class SocialPost {
  final List<NewHiveComment>? children;
  final String? body;

  SocialPost({
    required this.children,
    required this.body,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) => SocialPost(
        children:json["children"]!=null ? List<NewHiveComment>.from(
            json["children"].map((x) {
              if(x!=null){
                return NewHiveComment.fromJson(x);
              }
            })) : [],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "children": List<dynamic>.from(children!.map((x) => x.toJson())),
        "body": body,
      };
}

class NewHiveComment {
  final String? body;
  final String permlink;
  final DateTime? createdAt;
  final Author author;
  final Stats? stats;
  final List<NewHiveComment>? children;

  NewHiveComment({
    required this.body,
    required this.permlink,
    required this.createdAt,
    required this.author,
    required this.stats,
    required this.children,
  });

  factory NewHiveComment.fromJson(Map<String, dynamic> json) => NewHiveComment(
        body: json["body"],
        permlink: json["permlink"],
        createdAt: DateTime.parse(json["created_at"]),
        author: Author.fromJson(json["author"]),
        stats: Stats.fromJson(json["stats"]),
        children:json["children"]!=null ? List<NewHiveComment>.from(json["children"].map((x) {
          if (x != null) {
            return NewHiveComment.fromJson(x);
          }
        })) : [],
      );

  Map<String, dynamic> toJson() => {
        "body": body,
        "permlink": permlink,
        "created_at": createdAt?.toIso8601String(),
        "author": author.toJson(),
        "stats": stats?.toJson(),
        "children": children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
      };
}

class Author {
  final String username;

  Author({
    required this.username,
  });

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
      };
}

class Stats {
  final int? numVotes;

  Stats({
    required this.numVotes,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
        numVotes: json["num_votes"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "num_votes": numVotes,
      };
}
