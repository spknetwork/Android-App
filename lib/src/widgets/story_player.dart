import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    required this.playUrl,
    required this.thumbnail,
    required this.width,
    required this.height,
  }) : super(key: key);
  final String playUrl;
  final String thumbnail;
  final double width;
  final double height;

  @override
  _StoryPlayerState createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: widget.width / widget.height,
      fit: BoxFit.fill,
      autoPlay: true,
      // fullScreenByDefault: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        showControlsOnInitialize: false,
      ),
      deviceOrientationsOnFullScreen: [DeviceOrientation.portraitUp],
      // fullScreenByDefault: true,
      // placeholder: FadeInImage.assetNetwork(
      //   placeholder: 'assets/branding/three_speak_logo.png',
      //   image: widget.thumbnail,
      //   fit: BoxFit.fill,
      //   placeholderErrorBuilder:
      //       (BuildContext context, Object error, StackTrace? stackTrace) {
      //     return Image.asset('assets/branding/three_speak_logo.png');
      //   },
      //   imageErrorBuilder:
      //       (BuildContext context, Object error, StackTrace? stackTrace) {
      //     return Image.asset('assets/branding/three_speak_logo.png');
      //   },
      // ),
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    _betterPlayerController.setControlsEnabled(false);
    _betterPlayerController.setControlsAlwaysVisible(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(
      controller: _betterPlayerController,
      key: _betterPlayerKey,
    );
  }
}
