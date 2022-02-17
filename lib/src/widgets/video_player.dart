import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:acela/src/widgets/controls_overlay.dart';

class SPKVideoPlayer extends StatefulWidget {
  const SPKVideoPlayer({Key? key, required this.playUrl}) : super(key: key);
  final String playUrl;

  @override
  _SPKVideoPlayerState createState() => _SPKVideoPlayerState();
}

class _SPKVideoPlayerState extends State<SPKVideoPlayer>
    with AutomaticKeepAliveClientMixin<SPKVideoPlayer> {
  late VideoPlayerController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    controller = VideoPlayerController.network(widget.playUrl,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(controller),
                  ClosedCaption(text: controller.value.caption.text),
                  ControlsOverlay(controller: controller),
                  VideoProgressIndicator(controller, allowScrubbing: true),
                ],
              ),
            )
          : const LoadingScreen(),
    );
  }
}
