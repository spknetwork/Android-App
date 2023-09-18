import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PodcastController extends ChangeNotifier {
  var externalDir;

  PodcastController() {
    init();
  }

  void init() async {
    externalDir = await getExternalStorageDirectory();
  }

  bool isOffline(String name) {
    if (externalDir != null) {
      print(externalDir.listSync());
      for (var item in externalDir.listSync()) {
        if (decodeAudioName(item.path) == decodeAudioName(name)) {
          print('offline');
          return true;
        }
      }
    }
    print('online');
    return false;
  }

  String getOfflineUrl(String url) {
    for (var item in externalDir.listSync()) {
      if (decodeAudioName(item.path) == decodeAudioName(url)) {
        return item.path.toString();
      }
    }
    return "";
  }

  String decodeAudioName(String name) {
    return name.split('/').last;
  }
}
