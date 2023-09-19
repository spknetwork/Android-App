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
    for (var item in externalDir.listSync()) {
      item.delete();
    }
  }

  bool isOffline(String name, String episodeId) {
    if (externalDir != null) {
      print(externalDir.listSync());
      for (var item in externalDir.listSync()) {
        if (decodeAudioName(item.path,) ==
            decodeAudioName(name, episodeId:episodeId)) {
          print('offline');
          return true;
        }
      }
    }
    print('online');
    return false;
  }

  String getOfflineUrl(String url, String episodeId) {
    for (var item in externalDir.listSync()) {
      if (decodeAudioName(item.path) ==
          decodeAudioName(url, episodeId: episodeId)) {
        return item.path.toString();
      }
    }
    return "";
  }

  String decodeAudioName(String name, {String? episodeId}) {
    String decodedName = name.split('/').last;
    if (episodeId == null) {
      return decodedName;
    }
    return "$episodeId$decodedName";
  }
}
