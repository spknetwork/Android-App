import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/podcast_controller.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PodcastEpisodePlayer extends StatefulWidget {
  const PodcastEpisodePlayer({
    Key? key,
    required this.episode,
    required this.didFinish,
    required this.data,
  });

  final PodcastEpisode episode;
  final Function didFinish;
  final HiveUserData data;

  @override
  State<PodcastEpisodePlayer> createState() => _PodcastEpisodePlayerState();
}

class _PodcastEpisodePlayerState extends State<PodcastEpisodePlayer> {
  // late final externalDir;
  // bool showPlayer = false;
  // final assetsAudioPlayer = AssetsAudioPlayer();

  late final PodcastController podcastController;

  @override
  void initState() {
    super.initState();
    podcastController = context.read<PodcastController>();
    // initDirectory();
  }

  initDirectory() async {
    // externalDir = await getExternalStorageDirectory();
    // setState(() {
    //   showPlayer = true;
    //   print(externalDir!.listSync());
    //   print(externalDir!.listSync()[1].path);
    //   // assetsAudioPlayer.open(Audio.file(externalDir!.listSync()[1].path));
    // });
  }

  List<Widget> _fabButtonsOnRight() {
    return [
      IconButton(
        icon: Icon(Icons.share, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          Share.share(widget.episode.guid ?? '');
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
    var duration = widget.episode.duration?.toDouble() ?? 0.0;
    var pending = duration - position;
    var pendingText = "${Utilities.formatTime(pending.toInt())}";
    var leadingText = "${Utilities.formatTime(position.toInt())}";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 15),
        Text(leadingText),
        Spacer(),
        IconButton(
          icon: Icon(
            play ? Icons.pause : Icons.play_arrow,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              play = !play;
            });
          },
        ),
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
        IconButton(
          icon: Icon(Icons.share, color: Colors.blue),
          onPressed: () {
            // _betterPlayerController.pause();
            Share.share(widget.episode.guid ?? '');
          },
        ),
        DownloadPodcastButton(episode: widget.episode),
        Spacer(),
        Text(pendingText),
        SizedBox(width: 15),
      ],
    );
  }

  var play = true;
  var position = 0.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: context
              .read<PodcastController>()
              .isOffline(widget.episode.enclosureUrl ?? "")
          ? AudioWidget.file(
              path: podcastController
                  .getOfflineUrl(widget.episode.enclosureUrl ?? ""),
              play: play,
              onFinished: () {
                widget.didFinish();
              },
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
            )
          : AudioWidget.network(
              url: widget.episode.enclosureUrl ?? '',
              play: play,
              onFinished: () {
                widget.didFinish();
              },
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
            ),
    );
  }

  Column child(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(widget.episode.image ?? ''),
        SizedBox(height: 10),
        Text(
          widget.episode.title ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 10),
        Slider(
          value: (position / (widget.episode.duration?.toDouble() ?? 0.0)),
          onChanged: (newValue) {},
        ),
        actionBar(),
      ],
    );
  }
}

enum DownloadStatus { downloading, downloaded, download }

class DownloadPodcastButton extends StatefulWidget {
  const DownloadPodcastButton({Key? key, required this.episode})
      : super(key: key);

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
      String id = data[0];
      // DownloadTaskStatus status = (data[1]);
      int progress = data[2];
      print(progress);
      if(data[1] == 0 || data[1] == 4 || data[1] == 5){
        setState(() {
          status = DownloadStatus.download;
        });
      }
      if (progress == 100) {
        setState(() {
          status = DownloadStatus.downloaded;
        });
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
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
      return Padding(
        padding: const EdgeInsets.only(left : 7.0),
        child: SizedBox(
          height: 17,
          width: 17,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: iconColor,
          ),
        ),
      );
    } else if (podcastController.isOffline(widget.episode.enclosureUrl ?? "") ||
        status == DownloadStatus.downloaded) {
      return Padding(
        padding: const EdgeInsets.only(left :7.0),
        child: Icon(
          Icons.check,
          color: iconColor,
        ),
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
    final id = FlutterDownloader.enqueue(
        url: url,
        savedDir: savePath,
        fileName: widget.episode.enclosureUrl!.split('/').last,
        showNotification: true,
        openFileFromNotification: true);
  }
}
