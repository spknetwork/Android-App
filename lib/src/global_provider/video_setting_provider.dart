import 'package:flutter/material.dart';

class VideoSettingProvider extends ChangeNotifier {
  bool isMuted = true;

  void changeMuteStatus(bool value) {
    isMuted = value;
    notifyListeners();
  }
}
