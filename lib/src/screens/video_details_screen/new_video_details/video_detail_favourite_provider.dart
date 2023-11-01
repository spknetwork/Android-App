import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:get_storage/get_storage.dart';

class VideoFavoriteProvider {
  final box = GetStorage();
  final String _likedVideoLocalKey = 'liked_video';
  final String _shortsVideoLocalKey = 'liked_shorts_video';

  List<GQLFeedItem> getLikedVideos({bool isShorts = false}) {
    final String key = !isShorts ? _likedVideoLocalKey : _shortsVideoLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      List<GQLFeedItem> items =
          json.map((e) => GQLFeedItem.fromJson(e)).toList();
      return items;
    } else {
      return [];
    }
  }

  //check if the liked podcast single episode is present locally
  bool isLikedVideoPresentLocally(GQLFeedItem item, {bool isShorts = false}) {
    final String key = !isShorts ? _likedVideoLocalKey : _shortsVideoLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) =>
          checkUniqueId('${item.author?.username}/${item.permlink}', element));
      return index != -1;
    } else {
      return false;
    }
  }

  //sotre the single podcast episode locally if user likes it
  void storeLikedVideoLocally(GQLFeedItem item, {bool isShorts = false,bool forceRemove = false}) {
    final String key = !isShorts ? _likedVideoLocalKey : _shortsVideoLocalKey;
    final String identifier = '${item.author?.username}/${item.permlink}';
    if (box.read(key) != null) {
      List json = box.read(key);
      int index =
          json.indexWhere((element) => checkUniqueId(identifier, element));
      if (index == -1 && !forceRemove) {
        json.add(item.toJson());
        box.write(key, json);
      } else {
        json.removeWhere((element) => checkUniqueId(identifier, element));
        box.write(key, json);
      }
    } else {
      box.write(key, [item.toJson()]);
    }
    print(box.read(key));
  }

  bool checkUniqueId(String id, dynamic value) {
    print(id == "${value['author']['username']}/${value['permlink']}");
    return id == "${value['author']['username']}/${value['permlink']}";
  }
}
