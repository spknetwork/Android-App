// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class SPKVideoPlayer extends StatefulWidget {
  const SPKVideoPlayer({Key? key, required this.playUrl}) : super(key: key);
  final String playUrl;

  @override
  _SPKVideoPlayerState createState() => _SPKVideoPlayerState();
}

class _SPKVideoPlayerState extends State<SPKVideoPlayer> {
  // late VideoPlayerController videoPlayerController;
  // ChewieController? chewieController;
  late BetterPlayerController _betterPlayerController;
  GlobalKey _betterPlayerKey = GlobalKey();

  // @override
  // void dispose() {
  //   super.dispose();
  //   videoPlayerController.dispose();
  // }

  // @override
  // void initState() {
  //   videoPlayerController = VideoPlayerController.network(widget.playUrl,
  //       videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
  //     ..initialize().then((_) {
  //       setState(() {
  //         chewieController = ChewieController(
  //           videoPlayerController: videoPlayerController,
  //           autoPlay: true,
  //           looping: false,
  //         );
  //       });
  //     });
  //   super.initState();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return chewieController == null
  //       ? const LoadingScreen()
  //       : Chewie(controller: chewieController!);
  // }

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
    _betterPlayerController.setBetterPlayerGlobalKey(_betterPlayerKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  BetterPlayer(
      controller: _betterPlayerController,
      key: _betterPlayerKey,
    );
  }
}
