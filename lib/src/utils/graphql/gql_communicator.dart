import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/models/hive_comments/new_hive_comment/new_hive_comment.dart';
import 'package:acela/src/models/trending_tags/trending_tags_response.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class GQLCommunicator {
  static const defaultGQLServer =
      "threespeak-union-graph-ql.sagarkothari88.one";
  // static const gqlServer = "https://union.us-02.infra.3speak.tv/api/v2/graphql";
  static const dataQuery =
      "{\n    items {\n      created_at\n      title\n      ... on HivePost {\n        permlink\n        lang\n        title\n        tags\n        spkvideo\n        stats {\n          num_comments\n          num_votes\n          total_hive_reward\n        }\n        author {\n          username\n        }\n      }\n    }\n  }\n}";

  Future<List<GQLFeedItem>> getGQLFeed(String operation, String query) async {
    const storage = FlutterSecureStorage();
    String union =
        await storage.read(key: 'union') ?? GQLCommunicator.defaultGQLServer;
    String gqlServer = "https://$union/api/v2/graphql";
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
      List<GQLFeedItem> items = [];
      if ((responseData.data?.trendingFeed?.items ?? []).isNotEmpty) {
        items = responseData.data?.trendingFeed?.items ?? [];
      } else if ((responseData.data?.socialFeed?.items ?? []).isNotEmpty) {
        items = responseData.data?.socialFeed?.items ?? [];
      } else if ((responseData.data?.relatedFeed?.items ?? []).isNotEmpty) {
        items = responseData.data?.relatedFeed?.items ?? [];
      } else if ((responseData.data?.searchFeed?.items ?? []).isNotEmpty) {
        items = responseData.data?.searchFeed?.items ?? [];
      }
      return items.where((element) => element.spkvideo != null).toList();
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }

  Future<TrendingTagResponse> getTrendingTags() async {
    var headers = {
      'Connection': 'keep-alive',
      'content-type': 'application/json',
    };
    const storage = FlutterSecureStorage();
    String union =
        await storage.read(key: 'union') ?? GQLCommunicator.defaultGQLServer;
    String gqlServer = "https://$union/api/v2/graphql";
    var request = http.Request('POST', Uri.parse(gqlServer));
    var query =
        "query TrendingTags {\n  trendingTags(limit: 50) {\n    tags {\n      score\n      tag\n    }\n  }\n}";
    request.body = json.encode(
        {"query": query, "operationName": "TrendingTags", "extensions": {}});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return TrendingTagResponse.fromRawJson(string);
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }

  Future<List<GQLFeedItem>> getTrendingFeed(
      bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('TrendingFeed',
        "query TrendingFeed {\n  trendingFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getTrendingTagFeed(
      String tag, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true, firstUpload: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { byTag: {_eq: \"$tag\"} \n ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('TrendingTagFeed',
        "query TrendingTagFeed {\n  trendingFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getFirstUploadsFeed(
      bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true, firstUpload: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('FirstUploadsFeed',
        "query FirstUploadsFeed {\n  trendingFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getNewUploadsFeed(
      bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('NewUploadsFeed',
        "query NewUploadsFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getMyFeed(
      String username, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { byFollower: \"$username\"${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('MyFeed',
        "query MyFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getRelated(
      String author, String permlink, String? lang) async {
    var spkVideoQuery =
        "\nauthor: \"$author\", permlink: \"$permlink\"\nspkvideo: {only: true }\n";
    var feedOptionsQuery =
        "\nfeedOptions: { ${lang != null ? "byLang: {_eq: \"$lang\"}" : ""} }\n";
    return getGQLFeed('RelatedFeed',
        "query RelatedFeed {\n  relatedFeed($spkVideoQuery$feedOptionsQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getUserFeed(
      List<String> authors, bool isShorts, int skip, String? lang) async {
    var authorsQuery = "{_in: [${authors.map((e) => '"$e"').join(",")}]}";
    var spkVideoQuery =
        "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { byCreator: $authorsQuery ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('UserChannelFeed',
        "query UserChannelFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getSearchFeed(
      String term, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nsearchTerm: \"$term\"\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('SearchFeed',
        "query SearchFeed {\n  searchFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getCommunity(
      String community, bool isShorts, int skip, String? lang) async {
    var spkVideoQuery =
        "\nspkvideo: {only: true${isShorts ? ", isShort: true" : ""}}\n";
    var feedOptionsQuery =
        "\nfeedOptions: { byCommunity: { _eq: \"$community\" } ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('CommunityFeed',
        "query CommunityFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  Future<List<GQLFeedItem>> getCTTFeed(int skip, String? lang) async {
    var authors = ["spknetwork.chat", "neopch.ctt", "noakmilo.ctt"];
    var authorsQuery = "{_in: [${authors.map((e) => '"$e"').join(",")}]}";
    var spkVideoQuery = "\nspkvideo: {only: true }\n";
    var feedOptionsQuery =
        "\nfeedOptions: { byCreator: $authorsQuery ${lang != null ? ", byLang: {_eq: \"$lang\"}" : ""} }\n";
    var paginationQuery = "\npagination: { limit: 50, skip: $skip }\n";
    return getGQLFeed('UserChannelFeed',
        "query UserChannelFeed {\n  socialFeed($spkVideoQuery$feedOptionsQuery$paginationQuery)\n$dataQuery");
  }

  static Future<List<NewHiveComment>> getHiveComments(String userName,String permLink) async {
    try{
    var headers = {
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
      'Origin': 'https://union.us-02.infra.3speak.tv',
      'Referer':
          'https://union.us-02.infra.3speak.tv/api/v2/graphql?query=query+MyQuery+%7B%0A++socialPost%28author%3A+%22$userName%22%2C+permlink%3A+%22$permLink%22%29+%7B%0A++++...+on+HivePost+%7B%0A++++++children+%7B%0A++++++++...+on+HivePost+%7B%0A++++++++++body%0A++++++++++permlink%0A%09++created_at%0A++++++++++author+%7B%0A++++++++++++username%0A++++++++++%7D%0Astats+%7B%0A++++++++++num_votes%0A++++++++%7D%0A++++++++++children+%7B%0A++++++++++++...+on+HivePost+%7B%0A++++++++++++++body%0A++++++++++++++permlink%0A%09++++++created_at%0A++++++++++++++author+%7B%0A++++++++++++++++username%0A++++++++++++++%7D%0Astats+%7B%0A++++++++++num_votes%0A++++++++%7D%0A++++++++++++%7D%0A++++++++++++children+%7B%0A++++++++++++++++...+on+HivePost+%7B%0A++++++++++++++++++++++body%0A+++++++++++++++++++++++permlink%0A%09++%09+++++++created_at%0A++++++++++++++++++++++author+%7B%0A++++++++++++++++++++username%0A++++++++++++++++++++++%7D%0Astats+%7B%0A++++++++++num_votes%0A++++++++%7D%0A++++++++++++++++%7D%0A+++++++++++++%7D%0A++++++++++%7D%0A++++++++%7D%0A++++++%7D%0A++++++body%0A++++%7D%0A++%7D%0A%7D',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      'accept':
          'application/graphql-response+json, application/json, multipart/mixed',
      'content-type': 'application/json',
      'sec-ch-ua':
          '"Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"',
      'sec-ch-ua-mobile': '?1',
      'sec-ch-ua-platform': '"Android"'
    };
    var request = http.Request('POST',
        Uri.parse('https://union.us-02.infra.3speak.tv/api/v2/graphql'));
    request.body = json.encode({
      "query":
          "query MyQuery {\n  socialPost(author: \"$userName\", permlink: \"$permLink\") {\n    ... on HivePost {\n      children {\n        ... on HivePost {\n          body\n          permlink\n          created_at\n          author {\n            username\n          }\n          stats {\n            num_votes\n          }\n          children {\n            ... on HivePost {\n              body\n              permlink\n              created_at\n              author {\n                username\n              }\n              stats {\n                num_votes\n              }\n            }\n            children {\n              ... on HivePost {\n                body\n                permlink\n                created_at\n                author {\n                  username\n                }\n                stats {\n                  num_votes\n                }\n              }\n            }\n          }\n        }\n      }\n      body\n    }\n  }\n}",
      "operationName": "MyQuery",
      "extensions": {}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return HiveCommentData.fromRawJson(string).data.socialPost.children  ?? [];
    } else {
      throw response.reasonPhrase ?? 'Error occurred';
    }
  }
  catch(e){
     throw e;
  }
  }
}
