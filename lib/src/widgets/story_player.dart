import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer(
      {Key? key,
      required this.playUrl,
      required this.width,
      required this.height,
      required this.didFinish,
      required this.fitWidth})
      : super(key: key);
  final String playUrl;
  final double width;
  final double height;
  final Function didFinish;
  final bool fitWidth;

  @override
  _StoryPlayerState createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerConfiguration config;

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  @override
  void initState() {
    config = BetterPlayerConfiguration(
      aspectRatio: widget.width / widget.height,
      fit: BoxFit.fitHeight,
      autoPlay: true,
      fullScreenByDefault: false,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
      autoDispose: true,
      expandToFill: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: true,
        showControlsOnInitialize: true,
      ),
      showPlaceholderUntilPlay: true,
      allowedScreenSleep: false,
      eventListener: (event) {
        log('type - ${event.betterPlayerEventType.toString()}');
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          widget.didFinish();
        }
      },
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl.replaceAll("/manifest.m3u8", "/480p/index.m3u8"),
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(config);
    _betterPlayerController.setupDataSource(dataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(
      controller: _betterPlayerController,
    );
  }
}
