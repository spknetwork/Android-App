import 'dart:isolate';
import 'dart:ui';
import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

enum DownloadStatus { downloading, downloaded, download, cancelDownload }

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
  late DownloadStatus status;
  String? taskId;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    podcastController = context.read<PodcastController>();
    _setStatusOnEpisodeChange();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) async {
      // String id = data[0];
      // DownloadTaskStatus statuss = (data[1]);
      int progress = data[2];
      downloadProgress.value = progress.toDouble();
      print('progess is $progress');
      if (progress == 100 &&
          status == DownloadStatus.downloading &&
          taskId != null) {
         podcastController.storeOfflinePodcastLocally(widget.episode);
        setState(() {
          status = DownloadStatus.downloaded;
        });
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _setStatusOnEpisodeChange() {
    if (podcastController.isOffline(
        widget.episode.enclosureUrl ?? "", widget.episode.id.toString())) {
      status = DownloadStatus.downloaded;
    } else {
      status = DownloadStatus.download;
    }
  }

  @override
  void didUpdateWidget(covariant DownloadPodcastButton oldWidget) {
    if (oldWidget.episode.id != widget.episode.id) {
      if (status == DownloadStatus.downloading) {
        setState(() {
          _cancelAndRemove(taskId);
          status = DownloadStatus.download;
          taskId = null;
        });
      } else {
        setState(() {
          _setStatusOnEpisodeChange();
        });
      }
    }
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
    if (status == DownloadStatus.downloading ||
        status == DownloadStatus.cancelDownload) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: ValueListenableBuilder<double>(
                valueListenable: downloadProgress,
                builder: (context, progress, child) {
                  return CircularProgressIndicator(
                    strokeWidth: 2,
                    value: status == DownloadStatus.cancelDownload
                        ? null
                        : progress / 100,
                    valueColor: AlwaysStoppedAnimation<Color?>(iconColor),
                    backgroundColor: theme.primaryColorLight.withOpacity(0.4),
                  );
                }),
          ),
          Visibility(
            visible: true,
            maintainAnimation: true,
            maintainSemantics: true,
            maintainSize: true,
            maintainState: true,
            child: IconButton(
                onPressed: _cancelDownload,
                icon: Icon(
                  Icons.stop,
                  size: 17.5,
                )),
          )
        ],
      );
    } else if (status == DownloadStatus.download) {
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
    } else {
      return Icon(
        Icons.check,
        color: iconColor,
      );
    }
  }

  void _cancelDownload() async {
    if (taskId != null) {
      setState(() {
        status = DownloadStatus.cancelDownload;
      });
      await _cancelAndRemove(taskId);
      setState(() {
        taskId = null;
        status = DownloadStatus.download;
      });
    }
  }

  Future<void> _cancelAndRemove(String? taskId) async {
    if (taskId != null) {
      await FlutterDownloader.cancel(taskId: taskId);
      await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
    }
  }

  void download(String url, String savePath) async {
    downloadProgress.value = 0;
    setState(() {
      status = DownloadStatus.downloading;
    });
    taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savePath,
      fileName: podcastController.decodeAudioName(widget.episode.enclosureUrl!,
          episodeId: widget.episode.id.toString(),
          isAudio: widget.episode.isAudio),
      showNotification: true,
      openFileFromNotification: true,
    );
  }
}
