import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class PodcastController extends ChangeNotifier {
  final box = GetStorage();
  final String _likedPodcastEpisodeLocalKey = 'liked_podcast_episode';
  final String _likedPodcastLocalKey = 'liked_podcast';
  final String _offlinePodcastLocalKey = 'offline_podcast';
  var externalDir;

  PodcastController() {
    init();
  }

  void init() async {
    externalDir = await getExternalStorageDirectory();
  }

  bool isOffline(String name, String episodeId) {
    if (externalDir != null) {
      for (var item in externalDir.listSync()) {
        if (decodeAudioName(
              item.path,
            ) ==
            decodeAudioName(name, episodeId: episodeId)) {
          // print('offline');
          return true;
        }
      }
    }
    // print('online');
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
    String target = ".mp3";
    int index = decodedName.indexOf(target);
    if (index != -1) {
      decodedName = decodedName.substring(0, index + target.length);
    }
    if (episodeId == null) {
      return decodedName;
    }
    return "$episodeId$decodedName";
  }

  //retrieve liked podcast from local
  List<PodCastFeedItem> getLikedPodcast({bool filterOnlyRssPodcasts = false}) {
    final String key = _likedPodcastLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      List<PodCastFeedItem> items = [];
      for (var item in json) {
        if (!filterOnlyRssPodcasts) {
          items.add(PodCastFeedItem.fromJson(item));
        } else if (item['rssUrl'] != null) {
          items.add(PodCastFeedItem.fromJson(item));
        }
      }
      return items;
    } else {
      return [];
    }
  }

  //check if the liked podcast is present in your local
  bool isLikedPodcastPresentLocally(PodCastFeedItem item) {
    final String key = _likedPodcastLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      return index != -1;
    } else {
      return false;
    }
  }

  //store the podcast locally if user likes it
  void storeLikedPodcastLocally(PodCastFeedItem item) {
    final String key = _likedPodcastLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      if (index == -1) {
        json.add(item.toJson());
        box.write(key, json);
      } else {
        json.removeWhere((element) => element['id'] == item.id);
        box.write(key, json);
      }
    } else {
      box.write(key, [item.toJson()]);
    }
    notifyListeners();
  }

  //check if the liked podcast single episode is present locally
  bool isLikedPodcastEpisodePresentLocally(PodcastEpisode item) {
    final String key = _likedPodcastEpisodeLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      return index != -1;
    } else {
      return false;
    }
  }

  //sotre the single podcast episode locally if user likes it
  void storeLikedPodcastEpisodeLocally(PodcastEpisode item,{bool forceRemove=false}) {
    final String key = _likedPodcastEpisodeLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      if (index == -1 && !forceRemove) {
        json.add(item.toJson());
        box.write(key, json);
      } else {
        json.removeWhere((element) => element['id'] == item.id);
        box.write(key, json);
      }
    } else {
      box.write(key, [item.toJson()]);
    }
  }

  //after downloaing a podcast episode store it locally
  void storeOfflinePodcastLocally(PodcastEpisode episode) {
    final String key = _offlinePodcastLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      json.add(episode.toJson());
      box.write(key, json);
    } else {
      box.write(key, [episode.toJson()]);
    }
  }

  //retrieve the single podcast episodes for liked or offline
  List<PodcastEpisode> likedOrOfflinepodcastEpisodes(
      {required bool isOffline}) {
    final box = GetStorage();
    final String key =
        isOffline ? _offlinePodcastLocalKey : _likedPodcastEpisodeLocalKey;
    if (box.read(key) != null) {
      List json = box.read(key);
      List<PodcastEpisode> items =
          json.map((e) => PodcastEpisode.fromJson(e)).toList();
      return items;
    } else {
      return [];
    }
  }

  void deleteOfflinePodcastEpisode(PodcastEpisode episode) {
    if (externalDir != null) {
      for (int i = 0; i < externalDir.listSync().length; i++) {
        var item = externalDir.listSync()[i];
        if (decodeAudioName(
              item.path,
            ) ==
            decodeAudioName(episode.enclosureUrl ?? "",
                episodeId: episode.id)) {
          externalDir.listSync()[i].delete();
          final String key = _offlinePodcastLocalKey;
          if (box.read(key) != null) {
            List json = box.read(key);
            json.removeWhere((element) => element['id'] == episode.id);
            box.write(key, json);
          }
        }
      }
    }
  }
}
