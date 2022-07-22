import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_recommendation_models/video_recommendation.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;

class VideoDetailsViewModel {
  String author;
  String permlink;

  VideoDetailsViewModel({required this.author, required this.permlink});

  Future<VideoDetails> getVideoDetails() async {
    final endPoint = "${server.domain}/apiv2/@$author/$permlink";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      VideoDetails data = VideoDetails.fromJsonString(response.body);
      return data;
    } else {
      throw "Status code = ${response.statusCode}";
    }
  }

  Future<List<VideoRecommendationItem>> getRecommendedVideos() async {
    final endPoint = "${server.domain}/apiv2/recommended?v=$author/$permlink";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      var data = videoRecommendationItemsFromJson(response.body);
      return data;
    } else {
      throw "Status code = ${response.statusCode}";
    }
  }

  Future<List<HiveComment>> loadComments(String author, String permlink) async {
    var client = http.Client();
    var body =
        hiveCommentRequestToJson(HiveCommentRequest.from([author, permlink]));
    var response =
        await client.post(Uri.parse(Communicator.hiveApiUrl), body: body);
    if (response.statusCode == 200) {
      var hiveCommentsResponse = hiveCommentsFromString(response.body);
      var comments = hiveCommentsResponse.result;
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].children > 0) {
          if (comments
              .where((e) => e.parentPermlink == comments[i].permlink)
              .isEmpty) {
            var newComments =
                await loadComments(comments[i].author, comments[i].permlink);
            comments.insertAll(i + 1, newComments);
          }
        }
      }
      return comments;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Future<List<HiveComment>> loadFirstSetOfComments(
      String author, String permlink) async {
    var client = http.Client();
    var body =
        hiveCommentRequestToJson(HiveCommentRequest.from([author, permlink]));
    var response =
        await client.post(Uri.parse(Communicator.hiveApiUrl), body: body);
    if (response.statusCode == 200) {
      var hiveCommentsResponse = hiveCommentsFromString(response.body);
      var comments = hiveCommentsResponse.result;
      return comments;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }
}
