import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ImageResolution extends ChangeNotifier {
  late String _resolution;
  String storageKey = 'videoImageResolution';
  GetStorage _storage = GetStorage();

  ImageResolution() {
    _init();
  }

  void _init() {
    _resolution = _storage.read(storageKey) ?? Resolution.r480;
  }

  set resolution(String newResolution) {
    if (newResolution != _resolution) {
      _resolution = newResolution;
      _storage.write(storageKey, newResolution);
      notifyListeners();
    }
  }

  String get resolution {
    String resolutionString = _resolution.toString().replaceAll('r', '');
    return resolutionString;
  }
}

class Resolution {
  static String r360 = '360p';
  static String r480 = '480p';
  static String r720 = '720p';
  static String r1080 = '1080p';

  static removePFromResolution(String resolution) {
    String actualResolution = resolution.replaceAll('p', '');
    return actualResolution;
  }
}
