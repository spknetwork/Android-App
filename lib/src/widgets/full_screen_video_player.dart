import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SPKFullScreenVideoPlayer extends StatefulWidget {
  const SPKFullScreenVideoPlayer({Key? key, required this.playUrl}) : super(key: key);
  final String playUrl;

  @override
  _SPKFullScreenVideoPlayerState createState() => _SPKFullScreenVideoPlayerState();
}

class _SPKFullScreenVideoPlayerState extends State<SPKFullScreenVideoPlayer> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
    BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      // fit: BoxFit.contain,
      autoPlay: true,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: false,
      ),
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.portraitDown,
      ],
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
      autoDispose: true,
      expandToFill: true,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full screen player'),
      ),
      body: BetterPlayer(
        controller: _betterPlayerController,
      ),
    );
  }
}