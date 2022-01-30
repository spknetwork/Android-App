import 'package:http/http.dart' show get;
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';

class HomeScreenViewModel {
  Future<List<HomeFeed>> getHomeFeed() async {
    final endPoint = "${server.domain}/api/feed/more";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      List<HomeFeed> list = homeFeedFromJson(response.body);
      return list;
    } else {
      throw 'Something went wrong.\nStatus code is ${response.statusCode} for $endPoint';
    }
  }
}
