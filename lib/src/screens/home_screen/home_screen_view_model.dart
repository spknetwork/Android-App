import 'package:http/http.dart' show get;
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';

enum LoadState {
  notStarted,
  loading,
  succeeded,
  failed,
}

class HomeScreenViewModel {
  LoadState state = LoadState.notStarted;
  List<HomeFeed> list = [];
  String error = 'Something went wrong';
  Function() stateUpdated;

  HomeScreenViewModel({required this.path, required this.stateUpdated});
  final String path;

  Future loadHomeFeed() async {
    state = LoadState.loading;
    stateUpdated();
    var response = await get(Uri.parse(path));
    if (response.statusCode == 200) {
      List<HomeFeed> list = homeFeedFromJson(response.body);
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