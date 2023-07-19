import 'dart:convert';

import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:http/http.dart' as http;

class GQLCommunicator {
  static const gqlServer = "https://union.us-02.infra.3speak.tv/api/v2/graphql";

  Future<List<GQLFeedItem>> getGQLFeed(
      String operation,
      String query,
      bool trending
      ) async {
    var headers = {
      'Connection': 'keep-alive',
      'content-type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse(gqlServer));
    request.body = json.encode({
      "query": query,
      "operationName": operation,
      "extensions": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var responseData = GraphQlFeedResponse.fromRawJson(string);
      return trending ? responseData.data?.trendingFeed?.items ?? [] : responseData.data?.socialFeed?.items ?? [];
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }

  Future<List<GQLFeedItem>> getTrendingFeed() async {
    return getGQLFeed(
        'TrendingFeed',
        "query TrendingFeed {\n  trendingFeed(spkvideo: {only: true}) {\n    items {\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        true
    );
  }

  Future<List<GQLFeedItem>> getFirstUploadsFeed() async {
    return getGQLFeed(
        'FirstUploadsFeed',
        "query FirstUploadsFeed {\n  socialFeed(spkvideo: {only: true, firstUpload: true}, feedOptions: {}) {\n    items {\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        false
    );
  }

  Future<List<GQLFeedItem>> getNewUploadsFeed() async {
    return getGQLFeed(
        'NewUploadsFeed',
        "query NewUploadsFeed {\n  socialFeed(spkvideo: {only: true}) {\n    items {\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}",
        false
    );
  }
}
