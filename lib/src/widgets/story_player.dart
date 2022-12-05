import 'dart:developer';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    required this.playUrl,
    required this.thumbnail,
    required this.width,
    required this.height,
    required this.didFinish,
  }) : super(key: key);
  final String playUrl;
  final String thumbnail;
  final double width;
  final double height;
  final Function didFinish;

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
      // fullScreenByDefault: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        showControlsOnInitialize: false,
      ),
      fullScreenByDefault: false,
      autoDispose: true,
      eventListener: (event) {
        log('type - ${event.betterPlayerEventType.toString()}');
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          widget.didFinish();
        }
      },
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(config);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setControlsEnabled(false);
    _betterPlayerController.setControlsAlwaysVisible(false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(
      controller: _betterPlayerController,
    );
  }
}
