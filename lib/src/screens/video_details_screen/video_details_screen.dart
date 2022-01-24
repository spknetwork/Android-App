import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:flutter/material.dart';
// import 'package:better_player/better_player.dart';

import 'package:video_player/video_player.dart';

class VideoDetailsScreenArguments {
  final HomeFeed item;

  VideoDetailsScreenArguments(this.item);
}

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({Key? key}) : super(key: key);
  static const routeName = '/video_details';

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  VideoPlayerController? _controller;

  void initPlayer(String url) {
    _controller ??= VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {
            _controller?.play();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)!
        .settings
        .arguments
    as VideoDetailsScreenArguments;
    String url = args.item.ipfs == null
        ? "https://threespeakvideo.b-cdn.net/${args.item.permlink}/default.m3u8"
        : "https://ipfs-3speak.b-cdn.net/ipfs/${args.item.ipfs}/default.m3u8";
    initPlayer(url);
    return Scaffold(
      appBar: AppBar(
        title: Text(args.item.title),
      ),
      body:
      Center(
        child: _controller?.value.isInitialized ?? false
            ? AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller?.value.isPlaying ?? false
                ? _controller?.pause()
                : _controller?.play();
          });
        },
        child: Icon(
          _controller?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
