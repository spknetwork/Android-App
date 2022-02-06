import 'package:acela/src/utils/safe_convert.dart';
import 'active_vote.dart';
import 'dart:convert';

HiveComments hiveCommentsFromString(String string) {
  return HiveComments.fromJson(json.decode(string));
}

class HiveComments {
  final String jsonrpc;
  final List<HiveComment> result;
  final int id;

  HiveComments({
    this.jsonrpc = "",
    required this.result,
    this.id = 0,
  });

  factory HiveComments.fromJson(Map<String, dynamic>? json) => HiveComments(
        jsonrpc: asString(json, 'jsonrpc'),
        result:
            asList(json, 'result').map((e) => HiveComment.fromJson(e)).toList(),
        id: asInt(json, 'id'),
      );

  Map<String, dynamic> toJson() => {
        'jsonrpc': jsonrpc,
        'result': result.map((e) => e.toJson()),
        'id': id,
      };
}

class HiveComment {
  final String author;
  final String permlink;
  final String category;
  final String body;
  final String created;
  final int depth;
  final int children;
  final String lastPayout;
  final String cashoutTime;
  final String totalPayoutValue;
  final String curatorPayoutValue;
  final String pendingPayoutValue;
  final String parentAuthor;
  final String parentPermlink;
  final String url;
  final List<ActiveVote> activeVotes;

  HiveComment({
    this.author = "",
    this.permlink = "",
    this.category = "",
    this.body = "",
    this.created = "",
    this.depth = 0,
    this.children = 0,
    this.lastPayout = "",
    this.cashoutTime = "",
    this.totalPayoutValue = "",
    this.curatorPayoutValue = "",
    this.pendingPayoutValue = "",
    this.parentAuthor = "",
    this.parentPermlink = "",
    this.url = "",
    required this.activeVotes,
  });

  DateTime? get createdAt {
    return DateTime.tryParse(created);
  }

  factory HiveComment.fromJson(Map<String, dynamic>? json) => HiveComment(
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        category: asString(json, 'category'),
        body: asString(json, 'body'),
        created: asString(json, 'created'),
        depth: asInt(json, 'depth'),
        children: asInt(json, 'children'),
        lastPayout: asString(json, 'last_payout'),
        totalPayoutValue: asString(json, 'total_payout_value'),
        pendingPayoutValue: asString(json, 'pending_payout_value'),
        parentAuthor: asString(json, 'parent_author'),
        parentPermlink: asString(json, 'parent_permlink'),
        url: asString(json, 'url'),
        activeVotes: asList(json, 'active_votes')
            .map((e) => ActiveVote.fromJson(json))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'permlink': permlink,
        'category': category,
        'body': body,
        'created': created,
        'depth': depth,
        'children': children,
        'last_payout': lastPayout,
        'total_payout_value': totalPayoutValue,
        'pending_payout_value': pendingPayoutValue,
        'parent_author': parentAuthor,
        'url': url,
        'active_votes': activeVotes.map((e) => e),
      };
}
