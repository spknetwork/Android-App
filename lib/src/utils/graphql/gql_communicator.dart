import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:http/http.dart' as http;

class GQLCommunicator {
  static const gqlServer = "https://union.us-02.infra.3speak.tv/api/v2/graphql";
  static const dataQuery = "{\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}";

  Future<List<GQLFeedItem>> getGQLFeed(
      String operation, String query) async {
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

  Future<List<GQLFeedItem>> getTrendingFeed(bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'TrendingFeed',
        "query TrendingFeed {\n  trendingFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getFirstUploadsFeed(bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true, firstUpload: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'FirstUploadsFeed',
        "query FirstUploadsFeed {\n  trendingFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getNewUploadsFeed(bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'NewUploadsFeed',
        "query NewUploadsFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getMyFeed(
      String username, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { byFollower: \"$username\"${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'MyFeed',
        "query MyFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getRelated(String author, String permlink, String? lang) async {
    var spkVideoQuery = "\nauthor: \"$author\", permlink: \"$permlink\"\nspkvideo: {only: true }\n";
    var feedOptionsQuery = "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    return getGQLFeed(
        'RelatedFeed',
        "query RelatedFeed {\n  relatedFeed($spkVideoQuery$feedOptionsQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getUserFeed(String author, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { { byCreator: \"$author\" } ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'UserChannelFeed',
        "query UserChannelFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getCommunity(String community, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery = "\nfeedOptions: { { byCommunity: \"$community\" } ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'CommunityFeed',
        "query CommunityFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getCTTFeed(int skip, String? lang) async {
    var spkVideoQuery = "\nspkvideo: {only: true }\n";
    var feedOptionsQuery = "\nfeedOptions: { { byCreator: \"spknetwork.chat\" } ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed(
        'UserChannelFeed',
        "query UserChannelFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }
}
