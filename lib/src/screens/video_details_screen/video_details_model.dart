import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/models/video_details_model/video_details_description.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:http/http.dart' show get;
import 'package:acela/src/bloc/server.dart';

class VideoDetailsViewModel {
  LoadState descState = LoadState.notStarted;
  String descError = 'Something went wrong';
  Function() stateUpdated;
  HomeFeed item;
  VideoDetailsDescription? description;

  VideoDetailsViewModel({required this.stateUpdated, required this.item});

  Future loadVideoInfo() async {
    if (descState != LoadState.notStarted) return;
    descState = LoadState.loading;
    stateUpdated();
    final endPoint = "${server.domain}/apiv2/@${item.owner}/${item.permlink}";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      VideoDetailsDescription desc = videoDetailsDescriptionFromJson(response.body);
      descState = LoadState.succeeded;
      description = desc;
      stateUpdated();
    } else {
      descError =
          'Something went wrong.\nStatus code is ${response.statusCode} for $endPoint';
      descState = LoadState.failed;
      stateUpdated();
    }
  }
}
