import 'package:get_storage/get_storage.dart';

class TagFavoriteProvider {
  final box = GetStorage();
  final String _tagLocalKey = '_tagLocalKey';

  List getLikedTags() {
    final String key = _tagLocalKey;
    if (box.read(key) != null) {
      List items = box.read(key);
      return items;
    } else {
      return [];
    }
  }

  //check if the liked podcast single episode is present locally
  bool isTagPresentLocally(String tag) {
    final String key = _tagLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) =>
         element == tag);
      return index != -1;
    } else {
      return false;
    }
  }

  //sotre the single podcast episode locally if user likes it
  void storeLikedTagLocally(String tag,{bool forceRemove = false}) {
    final String key = _tagLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index =
          json.indexWhere((element) => element == tag);
      if (index == -1 && !forceRemove) {
        json.add(tag);
        box.write(key, json);
      } else {
        json.removeWhere((element) =>element == tag);
        box.write(key, json);
      }
    } else {
      box.write(key, [tag]);
    }
    print(box.read(key));
  }

}
