import 'dart:convert';

import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;

class PodCastCommunicator {
  static var baseUrl = "https://api.podcastindex.org/api/1.0/";

  Future<String> fetchPodCast(String path) async {
    var unixTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    String newUnixTime = unixTime.toString();
    var apiKey = dotenv.env['PC_API_KEY'] ?? '';
    var apiSecret = dotenv.env['PC_API_SECRET'] ?? '';
    var firstChunk = utf8.encode(apiKey);
    var secondChunk = utf8.encode(apiSecret);
    var thirdChunk = utf8.encode(newUnixTime);

    var output = new AccumulatorSink<Digest>();
    var input = sha1.startChunkedConversion(output);
    input.add(firstChunk);
    input.add(secondChunk);
    input.add(thirdChunk);
    input.close();
    var digest = output.events.single;

    Map<String, String> headers = {
      "X-Auth-Date": newUnixTime,
      "X-Auth-Key": apiKey,
      "Authorization": digest.toString(),
      "User-Agent": "ThreeSpeak/2.0.0+$newUnixTime"
    };

    var uriString = '$baseUrl$path';
    var uri = Uri.parse(uriString);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      log('response.body is ${response.body}');
      return response.body;
      // return PodCastIndex.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  Future<TrendingPodCastResponse> getTrendingPodcasts() async {
    var response = await fetchPodCast('podcasts/trending');
    return TrendingPodCastResponse.fromRawJson(response);
  }

  Future<PodcastEpisodesByFeedResponse> getPodcastEpisodesByFeedId(String feedId) async {
    var response = await fetchPodCast('/episodes/byfeedid?id=$feedId');
    return PodcastEpisodesByFeedResponse.fromRawJson(response);
  }
}
