import 'dart:isolate';
import 'dart:ui';

import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

enum DownloadStatus { downloading, downloaded, download }

class DownloadPodcastButton extends StatefulWidget {
  const DownloadPodcastButton({
    Key? key,
    required this.episode,
    required this.color,
  }) : super(key: key);

  final PodcastEpisode episode;
  final Color color;

  @override
  State<DownloadPodcastButton> createState() => _DownloadPodcastButtonState();
}

class _DownloadPodcastButtonState extends State<DownloadPodcastButton> {
  late PodcastController podcastController;
  final ValueNotifier<double> downloadProgress = ValueNotifier<double>(0);
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
      downloadProgress.value = progress.toDouble();
      print('progess is $progress');
      if (data[1] == 0 || data[1] == 4 || data[1] == 5) {
        setState(() {
          status = DownloadStatus.download;
        });
      }
      if (progress == 100 && status != DownloadStatus.downloaded) {
        podcastController.storeOfflinePodcastLocally(widget.episode);
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
    print(podcastController.isOffline(
        widget.episode.enclosureUrl ?? "", widget.episode.id.toString()));
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
    final theme = Theme.of(context);
    final iconColor = widget.color;
    if (status == DownloadStatus.downloading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: ValueListenableBuilder<double>(
            valueListenable: downloadProgress,
            builder: (context, progress, child) {
              return CircularProgressIndicator(
                strokeWidth: 2,
                value: progress / 100,
                valueColor: AlwaysStoppedAnimation<Color?>(iconColor),
                backgroundColor: theme.primaryColorLight.withOpacity(0.4),
              );
            }),
      );
    } else if (podcastController.isOffline(
            widget.episode.enclosureUrl ?? "", widget.episode.id.toString()) ||
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
                podcastController.externalDir?.path ?? "");
          } catch (e) {
            print("Error - ${e.toString()}");
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
      fileName: podcastController.decodeAudioName(widget.episode.enclosureUrl!,
          episodeId: widget.episode.id.toString(),isAudio: widget.episode.isAudio),
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}
