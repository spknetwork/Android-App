import 'dart:convert';

import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:http/http.dart' as http;

class GQLCommunicator {
  static const gqlServer = "https://union.us-02.infra.3speak.tv/api/v2/graphql";

  Future<List<GQLFeedItem>> getTrendingFeed() async {
    var headers = {
      'Connection': 'keep-alive',
      'content-type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse(gqlServer));
    request.body = json.encode({
      "query":
          "query TrendingFeed {\n  trendingFeed(spkvideo: {firstUpload: false}) {\n    items {\n      ... on HivePost {\n        stats {\n          total_hive_reward\n          num_votes\n          num_comments\n        }\n        spkvideo\n        permlink\n        lang\n        created_at\n        community\n        title\n        tags\n        author {\n          username\n        }\n        body\n      }\n    }\n  }\n}",
      "operationName": "TrendingFeed",
      "extensions": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var responseData = GraphQlFeedResponse.fromRawJson(string);
      return responseData.data?.trendingFeed?.items ?? [];
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }

  Future<List<GQLFeedItem>> getFirstUploadsFeed() async {
    var headers = {
      'Connection': 'keep-alive',
      'content-type': 'application/json',
    };
    var request = http.Request('POST', Uri.parse(gqlServer));
    request.body = json.encode({
      "query":
      "query FirstUploadsFeed {\n  trendingFeed(spkvideo: {firstUpload: true}) {\n    items {\n      ... on HivePost {\n        stats {\n          total_hive_reward\n          num_votes\n          num_comments\n        }\n        spkvideo\n        permlink\n        lang\n        created_at\n        community\n        title\n        tags\n        author {\n          username\n        }\n        body\n      }\n    }\n  }\n}",
      "operationName": "FirstUploadsFeed",
      "extensions": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var responseData = GraphQlFeedResponse.fromRawJson(string);
      return responseData.data?.trendingFeed?.items ?? [];
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }
}
