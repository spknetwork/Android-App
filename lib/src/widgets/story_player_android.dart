import 'package:acela/src/widgets/loading_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryPlayerAndroid extends StatefulWidget {
  const StoryPlayerAndroid({
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
  State<StoryPlayerAndroid> createState() => _StoryPlayerAndroidState();
}

class _StoryPlayerAndroidState extends State<StoryPlayerAndroid> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(
      widget.playUrl,
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: false,
      ),
    )..initialize().then((_) {
        setState(() {
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            aspectRatio: widget.width / widget.height,
            allowFullScreen: false,
            allowPlaybackSpeedChanging: false,
            showControls: false,
            showControlsOnInitialize: false,
            zoomAndPan: false,
            showOptions: false,
            autoPlay: true,
            looping: true,
          );
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return chewieController == null
        ? const LoadingScreen(title: 'Loading Video', subtitle: 'Please wait')
        : Chewie(controller: chewieController!);
  }
}
