import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class VideoOps {
  final bool success;
  final String data;
  VideoOps({
    required this.success,
    required this.data,
  });

  factory VideoOps.fromJson(Map<String, dynamic>? json) => VideoOps(
        success: asBool(json, 'success'),
        data: asString(json, 'data'),
      );

  factory VideoOps.fromJsonString(String jsonString) =>
      VideoOps.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data,
      };
}

/*
class VideoOps {
  final Comment comment;
  final CommentOptions commentOptions;
  final CustomJson customJson;

  VideoOps({
    required this.comment,
    required this.commentOptions,
    required this.customJson,
  });

  factory VideoOps.fromJson(Map<String, dynamic>? json) => VideoOps(
        comment: Comment.fromJson(asMap(json, 'comment')),
        commentOptions: CommentOptions.fromJson(asMap(json, 'comment_options')),
        customJson: CustomJson.fromJson(asMap(json, 'custom_json')),
      );

  Map<String, dynamic> toJson() => {
        'comment': comment.toJson(),
        'comment_options': commentOptions.toJson(),
        'custom_json': customJson.toJson(),
      };

  List<dynamic> toOpsJson() {
    return [
      ["comment", comment.toJson()],
      ["comment_options", commentOptions.toJson()],
      ["custom_json", customJson.toJson()],
    ];
  }

  String toOpsJsonString() {
    return json.encode(toOpsJson());
  }
}

class Comment {
  final String parentAuthor;
  final String parentPermlink;
  final String author;
  final String permlink;
  final String title;
  final String body;
  final String jsonMetadata;

  Comment({
    this.parentAuthor = "",
    this.parentPermlink = "",
    this.author = "",
    this.permlink = "",
    this.title = "",
    this.body = "",
    this.jsonMetadata = "",
  });

  factory Comment.fromJson(Map<String, dynamic>? json) => Comment(
        parentAuthor: asString(json, 'parent_author'),
        parentPermlink: asString(json, 'parent_permlink'),
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        title: asString(json, 'title'),
        body: asString(json, 'body'),
        jsonMetadata: asString(json, 'json_metadata'),
      );

  Map<String, dynamic> toJson() => {
        'parent_author': parentAuthor,
        'parent_permlink': parentPermlink,
        'author': author,
        'permlink': permlink,
        'title': title,
        'body': body,
        'json_metadata': jsonMetadata,
      };
}

class CommentOptions {
  final String author;
  final String permlink;
  final String maxAcceptedPayout;
  final int percentHbd;
  final bool allowVotes;
  final bool allowCurationRewards;
  final List<ExtensionsSubList> extensions;

  CommentOptions({
    this.author = "",
    this.permlink = "",
    this.maxAcceptedPayout = "",
    this.percentHbd = 0,
    this.allowVotes = false,
    this.allowCurationRewards = false,
    required this.extensions,
  });

  factory CommentOptions.fromJson(Map<String, dynamic>? json) => CommentOptions(
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        maxAcceptedPayout: asString(json, 'max_accepted_payout'),
        percentHbd: asInt(json, 'percent_hbd'),
        allowVotes: asBool(json, 'allow_votes'),
        allowCurationRewards: asBool(json, 'allow_curation_rewards'),
        extensions:
            asList(json, 'extensions').map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'permlink': permlink,
        'max_accepted_payout': maxAcceptedPayout,
        'percent_hbd': percentHbd,
        'allow_votes': allowVotes,
        'allow_curation_rewards': allowCurationRewards,
        'extensions': extensions.map((e) => e),
      };
}

class CustomJson {
  final List<String> requiredPostingAuths;
  final List<String> requiredAuths;
  final String id;
  final String json;

  CustomJson({
    required this.requiredPostingAuths,
    required this.requiredAuths,
    this.id = "",
    this.json = "",
  });

  factory CustomJson.fromJson(Map<String, dynamic>? json) => CustomJson(
        requiredPostingAuths: asList(json, 'required_posting_auths')
            .map((e) => e.toString())
            .toList(),
        requiredAuths:
            asList(json, 'required_auths').map((e) => e.toString()).toList(),
        id: asString(json, 'id'),
        json: asString(json, 'json'),
      );

  Map<String, dynamic> toJson() => {
        'required_posting_auths': requiredPostingAuths.map((e) => e),
        'required_auths': requiredAuths.map((e) => e),
        'id': id,
        'json': json,
      };
}
*/
