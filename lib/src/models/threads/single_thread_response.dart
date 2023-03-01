import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class SingleThreadResponse {
  final List<ThreadContentsItem> threadContents;

  SingleThreadResponse({
    required this.threadContents,
  });

  factory SingleThreadResponse.fromJson(Map<String, dynamic>? json) =>
      SingleThreadResponse(
        threadContents: asList(json, 'threadContents')
            .map((e) => ThreadContentsItem.fromJson(e))
            .toList(),
      );

  factory SingleThreadResponse.fromJsonString(String string) =>
      SingleThreadResponse.fromJson(json.decode(string));
}

class ThreadContentsItem {
  final Thread thread;
  final Content content;

  ThreadContentsItem({
    required this.thread,
    required this.content,
  });

  factory ThreadContentsItem.fromJson(Map<String, dynamic>? json) =>
      ThreadContentsItem(
        thread: Thread.fromJson(asMap(json, 'thread')),
        content: Content.fromJson(asMap(json, 'content')),
      );
}

class Thread {
  final int index;
  final String author;
  final String permlink;
  final String authorPerm;
  final int children;
  final bool deleted;

  Thread({
    this.index = 0,
    this.author = "",
    this.permlink = "",
    this.authorPerm = "",
    this.children = 0,
    this.deleted = false,
  });

  factory Thread.fromJson(Map<String, dynamic>? json) => Thread(
        index: asInt(json, 'index'),
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        authorPerm: asString(json, 'author_perm'),
        children: asInt(json, 'children'),
        deleted: asBool(json, 'deleted'),
      );
}

class Content {
  final String category;
  final String parentAuthor;
  final String parentPermlink;
  final String author;
  final String permlink;
  final String title;
  final String body;
  final String jsonMetadata;
  final String lastUpdate;
  final String created;
  final int depth;
  final int children;
  final String cashoutTime;

  // final List<Dynamic> activeVotes;
  final int authorReputation;
  final String rootAuthor;

  Content({
    this.category = "",
    this.parentAuthor = "",
    this.parentPermlink = "",
    this.author = "",
    this.permlink = "",
    this.title = "",
    this.body = "",
    this.jsonMetadata = "",
    this.lastUpdate = "",
    this.created = "",
    this.depth = 0,
    this.children = 0,
    this.cashoutTime = "",
    // required this.activeVotes,
    this.authorReputation = 0,
    this.rootAuthor = "",
  });

  factory Content.fromJson(Map<String, dynamic>? json) => Content(
        category: asString(json, 'category'),
        parentAuthor: asString(json, 'parent_author'),
        parentPermlink: asString(json, 'parent_permlink'),
        author: asString(json, 'author'),
        permlink: asString(json, 'permlink'),
        title: asString(json, 'title'),
        body: asString(json, 'body'),
        jsonMetadata: asString(json, 'json_metadata'),
        lastUpdate: asString(json, 'last_update'),
        created: asString(json, 'created'),
        depth: asInt(json, 'depth'),
        children: asInt(json, 'children'),
        cashoutTime: asString(json, 'cashout_time'),
        // activeVotes: asList(json, 'active_votes').map((e) => e.toString()).toList(),
        authorReputation: asInt(json, 'author_reputation'),
        rootAuthor: asString(json, 'root_author'),
      );
}
