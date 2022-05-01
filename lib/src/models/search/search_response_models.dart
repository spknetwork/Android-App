import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class SearchResponseModels {
  final double took;
  final int hits;
  final List<SearchResponseResultsItem> results;

  SearchResponseModels({
    this.took = 0.0,
    this.hits = 0,
    required this.results,
  });

  factory SearchResponseModels.fromJson(Map<String, dynamic>? json) =>
      SearchResponseModels(
        took: asDouble(json, 'took'),
        hits: asInt(json, 'hits'),
        results: asList(json, 'results')
            .map((e) => SearchResponseResultsItem.fromJson(e))
            .toList(),
      );

  factory SearchResponseModels.fromJsonString(String jsonString) =>
      SearchResponseModels.fromJson(json.decode(jsonString));

  Map<String, dynamic> toJson() => {
        'took': took,
        'hits': hits,
        'results': results.map((e) => e.toJson()),
      };
}

class SearchResponseResultsItem {
  final int id;
  final String author;
  final String permlink;
  final String category;
  final int children;
  final String authorRep;
  final String title;
  final String titleMarked;
  final String body;
  final String bodyMarked;
  final String imgUrl;
  final double payout;
  final int totalVotes;
  final int upVotes;
  final String createdAt;
  final List<String> tags;
  final String app;
  final int depth;

  SearchResponseResultsItem(
      {this.id = 0,
      this.author = "",
      this.permlink = "",
      this.category = "",
      this.children = 0,
      this.authorRep = "",
      this.title = "",
      this.titleMarked = "",
      this.body = "",
      this.bodyMarked = "",
      this.imgUrl = "",
      this.payout = 0.0,
      this.totalVotes = 0,
      this.upVotes = 0,
      this.createdAt = "",
      required this.tags,
      this.app = "",
      this.depth = 0});

  factory SearchResponseResultsItem.fromJson(Map<String, dynamic>? json) =>
      SearchResponseResultsItem(
          id: asInt(json, 'id'),
          author: asString(json, 'author'),
          permlink: asString(json, 'permlink'),
          category: asString(json, 'category'),
          children: asInt(json, 'children'),
          authorRep: asString(json, 'author_rep'),
          title: asString(json, 'title'),
          titleMarked: asString(json, 'title_marked'),
          body: asString(json, 'body'),
          bodyMarked: asString(json, 'body_marked'),
          imgUrl: asString(json, 'img_url'),
          payout: asDouble(json, 'payout'),
          totalVotes: asInt(json, 'total_votes'),
          upVotes: asInt(json, 'up_votes'),
          createdAt: asString(json, 'created_at'),
          tags: asList(json, 'tags').map((e) => e.toString()).toList(),
          app: asString(json, 'app'),
          depth: asInt(json, 'depth'));

  Map<String, dynamic> toJson() => {
        'id': id,
        'author': author,
        'permlink': permlink,
        'category': category,
        'children': children,
        'author_rep': authorRep,
        'title': title,
        'title_marked': titleMarked,
        'body': body,
        'body_marked': bodyMarked,
        'img_url': imgUrl,
        'payout': payout,
        'total_votes': totalVotes,
        'up_votes': upVotes,
        'created_at': createdAt,
        'tags': tags.map((e) => e),
        'app': app,
        'depth': depth
      };
}
