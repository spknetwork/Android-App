import 'dart:isolate';
import 'dart:ui';
import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/podcast_controller.dart';
import 'package:acela/src/screens/podcast/podcast_trending.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PodcastEpisodePlayer extends StatefulWidget {
  const PodcastEpisodePlayer(
      {Key? key,
      required this.data,
      required this.podcastEpisodes,
      this.episodeIndex});

  final List<PodcastEpisode> podcastEpisodes;
  final HiveUserData data;
  final int? episodeIndex;

  @override
  State<PodcastEpisodePlayer> createState() => _PodcastEpisodePlayerState();
}

class _PodcastEpisodePlayerState extends State<PodcastEpisodePlayer> {

  late final PodcastController podcastController;
  late PodcastEpisode curentPodcastEpisode;
  int currentPodcastEpisodeIndex = 0;
  var play = true;
  var position = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.episodeIndex != null) {
      currentPodcastEpisodeIndex = widget.episodeIndex!;
    }
    curentPodcastEpisode = widget.podcastEpisodes[currentPodcastEpisodeIndex];
    podcastController = context.read<PodcastController>();
  }

  List<Widget> _fabButtonsOnRight() {
    return [
      IconButton(
        icon: Icon(Icons.share, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          Share.share(curentPodcastEpisode.guid ?? '');
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.info, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          // var screen =
          // NewVideoDetailsInfo(
          //   appData: widget.data,
          //   item: widget.item,
          // );
          // var route = MaterialPageRoute(builder: (c) => screen);
          // Navigator.of(context).push(route);
        },
      ),
      SizedBox(height: 10),
    ];
  }

  Widget actionBar() {
    Color iconColor = Colors.blue;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
          visible: widget.podcastEpisodes.length > 0,
          child: IconButton(
            onPressed: _playPrevious,
            icon: Icon(
              Icons.skip_previous,
              color: currentPodcastEpisodeIndex == 0
                  ? iconColor.withOpacity(0.5)
                  : iconColor,
            ),
          ),
        ),
        IconButton(
            icon: Icon(
              play ? Icons.pause : Icons.play_arrow,
              color: iconColor,
            ),
            onPressed: _pausePlayer),
        IconButton(
          icon: Icon(Icons.info, color: iconColor),
          onPressed: () {
            // _betterPlayerController.pause();
            // var screen =
            // NewVideoDetailsInfo(
            //   appData: widget.data,
            //   item: widget.item,
            // );
            // var route = MaterialPageRoute(builder: (c) => screen);
            // Navigator.of(context).push(route);
          },
        ),
        IconButton(
          icon: Icon(Icons.share, color: iconColor),
          onPressed: () {
            // _betterPlayerController.pause();
            Share.share(curentPodcastEpisode.guid ?? '');
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DownloadPodcastButton(
            episode: curentPodcastEpisode,
          ),
        ),
        FavouriteWidget(
          iconColor: iconColor,
          isLiked: isItemPresentLocally(curentPodcastEpisode), onAdd: (){
          storeLikedPodcastLocally(curentPodcastEpisode);
        }, onRemove: (){
          storeLikedPodcastLocally(curentPodcastEpisode);
        }),
        Visibility(
          visible: widget.podcastEpisodes.length > 1,
          child: IconButton(
            onPressed: _playNext,
            icon: Icon(
              Icons.skip_next,
              color: currentPodcastEpisodeIndex ==
                      widget.podcastEpisodes.length - 1
                  ? iconColor.withOpacity(0.5)
                  : iconColor,
            ),
          ),
        ),
      ],
    );
  }

  bool isItemPresentLocally(PodcastEpisode item) {
    final box = GetStorage();
    final String key = 'liked_podcast_episode';
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      return index != -1;
    } else {
      return false;
    }
  }

  void storeLikedPodcastLocally(PodcastEpisode item) {
    final box = GetStorage();
    final String key = 'liked_podcast_episode';
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
    print(box.read(key));
  }

  void _pausePlayer() {
    setState(() {
      play = !play;
    });
  }

  void _playNext() {
    if (currentPodcastEpisodeIndex != widget.podcastEpisodes.length - 1) {
      setState(() {
        currentPodcastEpisodeIndex++;
        curentPodcastEpisode =
            widget.podcastEpisodes[currentPodcastEpisodeIndex];
      });
    }
  }

  void _playPrevious() {
    if (currentPodcastEpisodeIndex != 0) {
      setState(() {
        --currentPodcastEpisodeIndex;
        curentPodcastEpisode =
            widget.podcastEpisodes[currentPodcastEpisodeIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
      play = false;
    });
        return true;
      },
      child: SafeArea(child: _playerStatus()),
    );
  }

  Widget _playerStatus() {
    if (context
        .read<PodcastController>()
        .isOffline(curentPodcastEpisode.enclosureUrl ?? "",curentPodcastEpisode.id.toString())) {
      return AudioWidget.file(
        path: podcastController
            .getOfflineUrl(curentPodcastEpisode.enclosureUrl ?? "",curentPodcastEpisode.id.toString()),
        play: play,
        // onFinished: _playNext,
        child: child(context),
        onReadyToPlay: (duration) {
          //onReadyToPlay
        },
        onPositionChanged: (current, duration) {
          //onPositionChanged
          setState(() {
            position = current.inSeconds.toDouble();
          });
        },
      );
    } else {
      return AudioWidget.network(
        url: curentPodcastEpisode.enclosureUrl ?? '',
        play: play,
        // onFinished: _playNext,
        child: child(context),
        onReadyToPlay: (duration) {
          //onReadyToPlay
        },
        onPositionChanged: (current, duration) {
          //onPositionChanged
          setState(() {
            position = current.inSeconds.toDouble();
          });
        },
      );
    }
  }

  Column child(BuildContext context) {
    var duration = curentPodcastEpisode.duration?.toDouble() ?? 0.0;
    var pending = duration - position;
    var pendingText = "${Utilities.formatTime(pending.toInt())}";
    var leadingText = "${Utilities.formatTime(position.toInt())}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(curentPodcastEpisode.image ?? ''),
        SizedBox(height: 10),
        Text(
          curentPodcastEpisode.title ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text(leadingText),
              Expanded(
                child: Slider(
                  value: (position /
                      (curentPodcastEpisode.duration?.toDouble() ?? 0.0)),
                  onChanged: (newValue) {},
                ),
              ),
              Text(pendingText),
            ],
          ),
        ),
        actionBar(),
      ],
    );
  }
}

enum DownloadStatus { downloading, downloaded, download }

class DownloadPodcastButton extends StatefulWidget {
  const DownloadPodcastButton({
    Key? key,
    required this.episode,
  }) : super(key: key);

  final PodcastEpisode episode;
  @override
  State<DownloadPodcastButton> createState() => _DownloadPodcastButtonState();
}

class _DownloadPodcastButtonState extends State<DownloadPodcastButton> {
  late PodcastController podcastController;
  DownloadStatus status = DownloadStatus.download;

  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    podcastController = context.read<PodcastController>();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      // String id = data[0];
      // DownloadTaskStatus status = (data[1]);
      int progress = data[2];
      print(progress);
      if (data[1] == 0 || data[1] == 4 || data[1] == 5) {
        setState(() {
          status = DownloadStatus.download;
        });
      }
      if (progress == 100 && status != DownloadStatus.downloaded) {
        storeOfflinePodcastLocally(widget.episode);
        setState(() {
          status = DownloadStatus.downloaded;
        });
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void didUpdateWidget(covariant DownloadPodcastButton oldWidget) {
    if (oldWidget.episode.id != widget.episode.id) {
      if (status != DownloadStatus.download) {
        setState(() {
          status = DownloadStatus.download;
        });
      }
    }
    print(podcastController.isOffline(widget.episode.enclosureUrl ?? "",widget.episode.id.toString()));
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    FlutterDownloader.cancelAll();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  Widget _build(BuildContext context) {
    final iconColor = Colors.blue;
    if (status == DownloadStatus.downloading) {
      return SizedBox(
        height: 17,
        width: 17,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: iconColor,
        ),
      );
    } else if (podcastController.isOffline(widget.episode.enclosureUrl ?? "",widget.episode.id.toString()) ||
        status == DownloadStatus.downloaded) {
      return Icon(
        Icons.check,
        color: iconColor,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.download, color: iconColor),
        onPressed: () {
          try {
            download(widget.episode.enclosureUrl.toString(),
                podcastController.externalDir.path ?? "");
          } catch (e) {
            setState(() {
              status = DownloadStatus.download;
            });
          }
        },
      );
    }
  }

  void download(String url, String savePath) async {
    setState(() {
      status = DownloadStatus.downloading;
    });
     FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: podcastController.decodeAudioName(widget.episode.enclosureUrl!,episodeId:widget.episode.id.toString() ),
        showNotification: true,
        openFileFromNotification: true);
  }

  void storeOfflinePodcastLocally(PodcastEpisode episode) {
    final box = GetStorage();
    final String key = 'offline_podcast';
    if (box.read(key) != null) {
      List json = box.read(key);
      json.add(episode.toJson());
      box.write(key, json);
    } else {
      box.write(key, [episode.toJson()]);
    }
  }
}
