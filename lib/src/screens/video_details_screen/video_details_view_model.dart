import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/video_details_model/video_details_description.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:http/http.dart' show get;
import 'package:http/http.dart' as http;
import 'package:acela/src/bloc/server.dart';

class VideoDetailsViewModel {
  // loading info
  LoadState descState = LoadState.notStarted;
  String descError = 'Something went wrong';
  VideoDetailsDescription? description;

  // view
  String path;
  String author;
  String permlink;

  // loading comments
  LoadState commentsState = LoadState.notStarted;
  String commentsError = 'Something went wrong';
  List<HiveComment> comments = [];

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

}
