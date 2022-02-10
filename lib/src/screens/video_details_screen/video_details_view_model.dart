import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_details_model/video_details_description.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;

class VideoDetailsViewModel {
  // view
  String path;
  String author;
  String permlink;

  VideoDetailsViewModel(
      {required this.path, required this.author, required this.permlink});

  factory VideoDetailsViewModel.from(String path) {
    if (!path.contains("owner=") || !path.contains("permlink=")) {
      path = "/watch?owner=sagarkothari88&permlink=gqbffyah";
    }
    var comps = path
        .replaceAll("?", "&")
        .split("&")
        .where((element) =>
    element.contains('owner=') || element.contains('permlink='))
        .toList();
    if (comps.length < 2) {
      comps = "/watch?owner=sagarkothari88&permlink=gqbffyah"
          .replaceAll("?", "&")
          .split("&")
          .where((element) =>
      element.contains('owner=') || element.contains('permlink='))
          .toList();
    }
    comps.sort();
    var firstComp = comps[0].split("=");
    if (firstComp.length < 2) {
      firstComp[1] = "sagarkothari88";
    }
    var secondComp = comps[1].split("=");
    if (secondComp.length < 2) {
      secondComp[1] = "gqbffyah";
    }
    var author = firstComp[1];
    var permlink = secondComp[1];
    return VideoDetailsViewModel(
        path: path, author: author, permlink: permlink);
  }

  Future<VideoDetails> getVideoDetails() async {
    final endPoint =
        "${server.domain}/apiv2/@$author/$permlink";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      VideoDetails data = videoDetailsFromJson(response.body);
      return data;
    } else {
      throw "Status code = ${response.statusCode}";
    }
  }

  Future<List<HiveComment>> loadComments(String author, String permlink) async {
    var client = http.Client();
    var body =
    hiveCommentRequestToJson(HiveCommentRequest.from([author, permlink]));
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
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
}
