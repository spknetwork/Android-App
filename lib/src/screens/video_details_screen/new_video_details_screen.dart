import 'dart:io';

import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

class NewVideoDetailsScreen extends StatefulWidget {
  const NewVideoDetailsScreen({
    Key? key,
    required this.item,
    required this.appData,
  });

  final GQLFeedItem item;
  final HiveUserData appData;

  @override
  State<NewVideoDetailsScreen> createState() => _NewVideoDetailsScreenState();
}

class _NewVideoDetailsScreenState extends State<NewVideoDetailsScreen> {
  VideoSize? ratio;
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    loadRatio();
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }

  void setupVideo(String url, VideoSize size) {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: size.width / size.height,
      fit: BoxFit.contain,
      autoPlay: true,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: false,
        enableFullscreen: false,
        enableSkips: true,
      ),
      autoDetectFullscreenAspectRatio: false,
      autoDetectFullscreenDeviceOrientation: false,
      autoDispose: true,
      expandToFill: true,
      allowedScreenSleep: false,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Platform.isAndroid
          ? url.replaceAll("/manifest.m3u8", "/480p/index.m3u8")
          : url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  void loadRatio() async {
    var info = await Communicator()
        .getAspectRatio(widget.item.videoV2M3U8(widget.appData));
    setState(() {
      ratio = info;
      setupVideo(widget.item.videoV2M3U8(widget.appData), info);
    });
  }

  void fullscreenTapped() async {
    _betterPlayerController.pause();
    var position =
        await _betterPlayerController.videoPlayerController?.position;
    var seconds = position?.inSeconds;
    if (seconds == null) return;
    debugPrint('position is $position');
    const platform = MethodChannel('com.example.acela/auth');
    await platform.invokeMethod('playFullscreen', {
      'url': widget.item.spkvideo?.playUrl ?? '',
      'seconds': seconds,
    });
  }

  Widget _videoPlayerStack(double screenWidth) {
    if (ratio == null) return Container();
    return SizedBox(
      height: (ratio!.height >= ratio!.width) ? 460 : (ratio!.height * screenWidth / ratio!.width),
      child: Stack(
        children: [
          BetterPlayer(
            controller: _betterPlayerController,
          ),
          Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      onPressed: () {
                        fullscreenTapped();
                      },
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: ratio == null
            ? LoadingScreen(
                title: 'Loading data',
                subtitle: 'Please wait',
              )
            : _videoPlayerStack(width),
      ),
    );
  }
}
