import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:http/http.dart' show get;

class HomeScreenViewModel {
  HomeScreenViewModel({required this.path});
  final String path;

  Future<List<HomeFeedItem>> loadHomeFeed() async {
    var response = await get(Uri.parse(path));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }
}