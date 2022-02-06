import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:http/http.dart' show get;

enum LoadState {
  notStarted,
  loading,
  succeeded,
  failed,
}

class HomeScreenViewModel {
  LoadState state = LoadState.notStarted;
  List<HomeFeedItem> list = [];
  String error = 'Something went wrong';
  Function() stateUpdated;

  HomeScreenViewModel({required this.path, required this.stateUpdated});
  final String path;

  Future loadHomeFeed() async {
    state = LoadState.loading;
    stateUpdated();
    var response = await get(Uri.parse(path));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      state = LoadState.succeeded;
      this.list = list;
      stateUpdated();
    } else {
      error =
      'Something went wrong.\nStatus code is ${response.statusCode} for $path';
      state = LoadState.failed;
      stateUpdated();
    }
  }
}