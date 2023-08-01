import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:http/http.dart' as http;

class GQLCommunicator {
  static const gqlServer = "https://union.us-02.infra.3speak.tv/api/v2/graphql";

  Future<List<GQLFeedItem>> getGQLFeed(
      String operation, String query, bool trending) async {
    var headers = {
      'Connection': 'keep-alive',
      'content-type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse(gqlServer));
    log('Query is - $query');
    request.body = json
        .encode({"query": query, "operationName": operation, "extensions": {}});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var responseData = GraphQlFeedResponse.fromRawJson(string);
      var items = (responseData.data?.trendingFeed?.items ?? []).isNotEmpty
          ? responseData.data?.trendingFeed?.items ?? []
          : responseData.data?.socialFeed?.items ?? [];
      return items.where((element) => element.spkvideo != null).toList();
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }

  Future<List<GQLFeedItem>> getTrendingFeed(bool isShorts, int skip) async {
    return getGQLFeed(
        'TrendingFeed',
        "query TrendingFeed {\n  trendingFeed(spkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n${skip != 0 ? "pagination: {skip: $skip,  limit: 50}" : ""}\n) {\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        true);
  }

  Future<List<GQLFeedItem>> getFirstUploadsFeed(bool isShorts, int skip) async {
    return getGQLFeed(
        'FirstUploadsFeed',
        "query FirstUploadsFeed {\n  trendingFeed(spkvideo: {only: true, firstUpload: true${isShorts ? ", isShort: true" : ""}}, feedOptions: {}\n${skip != 0 ? "pagination: {skip: $skip,  limit: 50}" : ""}\n) {\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        false);
  }

  Future<List<GQLFeedItem>> getNewUploadsFeed(bool isShorts, int skip) async {
    return getGQLFeed(
        'NewUploadsFeed',
        "query NewUploadsFeed {\n  socialFeed(spkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n${skip != 0 ? "pagination: {skip: $skip,  limit: 50}" : ""}\n) {\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        false);
  }

  Future<List<GQLFeedItem>> getMyFeed(
      String username, bool isShorts, int skip) async {
    return getGQLFeed(
        'MyFeed',
        "query MyFeed {\n  socialFeed(\n    spkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n${skip != 0 ? "pagination: {skip: $skip,  limit: 50}" : ""}\n\n    feedOptions: {byFollower: \"$username\"}\n  ) {\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        true);
  }

  Future<List<GQLFeedItem>> getRelated(String author, String permlink) async {
    return getGQLFeed(
        'RelatedFeed',
        "query RelatedFeed {\n  relatedFeed(author: \"$author\", permlink: \"$permlink\") {\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        false);
  }
}
