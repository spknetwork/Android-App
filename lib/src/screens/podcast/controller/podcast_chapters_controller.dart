import 'package:acela/src/models/podcast/podcast_episode_chapters.dart';
import 'package:acela/src/screens/podcast/widgets/audio_player/action_tools.dart';
import 'package:acela/src/screens/podcast/widgets/audio_player/audio_player_core_controls.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:flutter/material.dart';

class PodcastChapterController extends ChangeNotifier {
  final AudioPlayerHandler audioPlayerHandler;
  List<PodcastEpisodeChapter>? chapters;
  final String? chapterUrl;
  int totalDuration;
  int currentDuration = 0;

  String? title;
  String? image;
  PodcastChapterController(
      {required this.chapterUrl,
      required this.totalDuration,
      required this.audioPlayerHandler}) {
    _loadChapters();
  }

  void _loadChapters() async {
    if (chapterUrl != null) {
      var result =
          await PodCastCommunicator().getPodcastEpisodeChapters(chapterUrl!);
      result.removeWhere((element) => element.toc != null);
      chapters = result;
      notifyListeners();
    } else {
      chapters = null;
    }
  }

  void jumpToNextChapter(Function callback) {
    if (chapters != null && chapters!.isNotEmpty) {
      int index = chapters!.indexWhere((element) {
        return element.startTime! > currentDuration;
      });
      if (index != -1) {
        _setChapterTitleAndImage(index);
        int startTime = chapters![index].startTime!;
        if (startTime > totalDuration) {
          callback();
        } else {
          audioPlayerHandler.seek(Duration(seconds: startTime));
        }
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  void jumpToPreviousChapter(Function callback) {
    if (chapters != null && chapters!.isNotEmpty) {
      int? index = _findNearestLessThan(checkEqual: false);
      if (index != null) {
        _setChapterTitleAndImage(index);
        int startTime = chapters![index].startTime!;
        if (startTime < 0) {
          callback();
        } else {
          audioPlayerHandler.seek(Duration(seconds: startTime));
        }
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  bool hasPreviousChapter() {
    if (chapters != null && chapters!.isNotEmpty) {
      int? index = _findNearestLessThan(checkEqual: false);
      if (index == 0 && currentDuration == 0) {
        return false;
      }  else {
        return index != null;
      }
    }
    return false;
  }

  bool hasNextChapter() {
    if (chapters != null && chapters!.isNotEmpty) {
      int index = chapters!.indexWhere((element) {
        return element.startTime! > currentDuration;
      });
      return index != -1;
    }
    return false;
  }

  void syncChapters({bool isInteracted = false, bool isReduced = false}) {
    if (chapters != null && chapters!.isNotEmpty) {
      if (!isInteracted) {
        int index = chapters!
            .indexWhere((element) => element.startTime == currentDuration);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _setChapterTitleAndImage(index);
        });
      } else {
        if (!isReduced) {
          int index = chapters!
              .indexWhere((element) => element.startTime == currentDuration);
          if (index == -1) {
            int newIndex = chapters!.indexWhere((element) {
              return element.startTime! > currentDuration;
            });
            if ((newIndex - 1 > 0)) {
              _setChapterTitleAndImage(newIndex - 1);
            } else {
              _setChapterTitleAndImage(0);
            }
          } else {
            _setChapterTitleAndImage(index);
          }
        } else {
          if (isReduced) {
            int? index = _findNearestLessThan();
            if (index != null) {
              _setChapterTitleAndImage(index);
            }
          }
        }
      }
    }
  }

  int? _findNearestLessThan({bool checkEqual = true}) {
    int? result;
    for (int i = 0; i < chapters!.length; i++) {
      if (checkEqual) {
        if (chapters![i].startTime == currentDuration) {
          return i;
        }
      }
      if (chapters![i].startTime! < currentDuration) {
        result = i;
      } else {
        return result;
      }
    }
    return result;
  }

  void _setChapterTitleAndImage(int index) {
    if (index != -1 && index < chapters!.length) {
      String? chapterTitle = chapters![index].title;
      String? chapterImage = chapters![index].image;
      if (chapterTitle != null) {
        title = chapterTitle;
      }
      if (chapterImage != null) {
        image = chapterImage;
      }
      notifyListeners();
    }
  }

  void setDurationData(PositionData data) {
    currentDuration = data.position.inSeconds;
    totalDuration = data.duration.inSeconds;
  }
}
