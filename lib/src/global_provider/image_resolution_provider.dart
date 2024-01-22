import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SettingsProvider extends ChangeNotifier {
  late String _resolution;
  late bool _autoPlayVideo;
  String _resolutionKey = 'videoImageResolution';
  String _autoPlayVideoKey = 'autoPlayVideo';
  GetStorage _storage = GetStorage();

  SettingsProvider() {
    _init();
  }

  void _init() {
    _resolution = _storage.read(_resolutionKey) ?? Resolution.r480;
    _autoPlayVideo = _storage.read(_autoPlayVideoKey) ?? true;
  }

  set resolution(String newResolution) {
    if (newResolution != _resolution) {
      _resolution = newResolution;
      _storage.write(_resolutionKey, newResolution);
      notifyListeners();
    }
  }

  String get resolution {
    String resolutionString = _resolution.toString().replaceAll('r', '');
    return resolutionString;
  }

   set autoPlayVideo(bool status) {
    if (status != _autoPlayVideo) {
      _autoPlayVideo = status;
      _storage.write(_autoPlayVideoKey, status);
      notifyListeners();
    }
  }

  bool get autoPlayVideo {
    return _autoPlayVideo;
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
