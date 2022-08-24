import 'package:acela/src/widgets/loading_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SPKVideoPlayerForAndroid extends StatefulWidget {
  const SPKVideoPlayerForAndroid({Key? key, required this.playUrl})
      : super(key: key);
  final String playUrl;

  @override
  _SPKVideoPlayerForAndroidState createState() =>
      _SPKVideoPlayerForAndroidState();
}

class _SPKVideoPlayerForAndroidState extends State<SPKVideoPlayerForAndroid> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.network(widget.playUrl,
        videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true))
      ..initialize().then((_) {
        setState(() {
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: true,
            looping: false,
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
