import 'dart:async';
import 'dart:developer';

class Server {
  final String domain = "https://3speak.tv";

  String userOwnerThumb(String value) {
    return "https://images.hive.blog/u/$value/avatar";
  }

  String userChannelCover(String value) {
    return "https://img.3speakcontent.co/user/$value/cover.png";
  }

  String communityIcon(String value) {
    return "https://images.hive.blog/u/$value/avatar?size=icon";
  }

  String resizedImage(String value) {
    return "https://images.hive.blog/320x160/$value";
  }

  final String hiveDomain = "https://api.hive.blog";

  final _controller = StreamController<bool>();

  Stream<bool> get theme {
    return _controller.stream;
  }

  void changeTheme(bool value) async {
    _controller.sink.add(!value);
  }
}

Server server = Server();