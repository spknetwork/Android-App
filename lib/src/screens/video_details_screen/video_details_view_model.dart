import 'package:acela/src/models/hive_comments/request/hive_comments_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
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
  Function() stateUpdated;
  HomeFeed item;

  // loading comments
  LoadState commentsState = LoadState.notStarted;
  String commentsError = 'Something went wrong';
  List<HiveComment> comments = [];

  VideoDetailsViewModel({required this.stateUpdated, required this.item});

  void loadVideoInfo() {
    if (descState != LoadState.notStarted) return;
    descState = LoadState.loading;
    stateUpdated();
    final endPoint = "${server.domain}/apiv2/@${item.owner}/${item.permlink}";
    get(Uri.parse(endPoint))
        .then((response) {
      VideoDetailsDescription desc =
      videoDetailsDescriptionFromJson(response.body);
      descState = LoadState.succeeded;
      description = desc;
      stateUpdated();
    }).catchError((error) {
      descError =
      'Something went wrong.\nError is $error';
      descState = LoadState.failed;
      stateUpdated();
    });
  }

  void loadComments(String author, String permlink) {
    if (commentsState != LoadState.notStarted) return;
    commentsState = LoadState.loading;
    var client = http.Client();
    var request = http.Request('POST', Uri.parse(server.hiveDomain));
    request.body =
        hiveCommentsRequestToJson(HiveCommentsRequest.from(author, permlink));
    client
        .send(request)
        .then((response) => response.stream.bytesToString())
        .then((value) {
      HiveComments hiveComments = hiveCommentsFromJson(value);
      commentsState = LoadState.succeeded;
      comments = hiveComments.result;
      stateUpdated();
      scanComments();
    }).catchError((error) {
      commentsError = 'Something went wrong.\nError is $error';
      commentsState = LoadState.failed;
      stateUpdated();
    });
  }

  void childrenComments(String author, String permlink, int index) {
    var client = http.Client();
    var request = http.Request('POST', Uri.parse(server.hiveDomain));
    request.body =
        hiveCommentsRequestToJson(HiveCommentsRequest.from(author, permlink));
    client
        .send(request)
        .then((response) => response.stream.bytesToString())
        .then((value) {
      HiveComments hiveComments = hiveCommentsFromJson(value);
      comments.insertAll(index + 1, hiveComments.result);
      stateUpdated();
      scanComments();
    }).catchError((error) {
      // commentsError = 'Something went wrong.\nError is $error';
      // commentsState = LoadState.failed;
      // stateUpdated();
    });
  }

  void scanComments() {
    for(var i=0; i < comments.length; i++) {
      if (comments[i].children > 0) {
        if (comments.where((e) => e.parentPermlink == comments[i].permlink).isEmpty) {
          childrenComments(comments[i].author, comments[i].permlink, i);
          break;
        }
      }
    }
  }
}
