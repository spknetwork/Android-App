import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_widgets.dart';
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
  final widgets = VideoDetailsScreenWidgets();
  VideoPlayerController? _controller;
  VideoDetailsViewModel? vm;

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void initPlayer(String url) {
    _controller ??= VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _controller?.play();
        });
      });
  }

  void initViewModel(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as VideoDetailsScreenArguments;
    vm ??= VideoDetailsViewModel(
        stateUpdated: () {
          setState(() {});
        },
        item: args.item);
    vm?.loadVideoInfo();
    vm?.loadComments(args.item.owner, args.item.permlink);
  }

  @override
  Widget build(BuildContext context) {
    initViewModel(context);
    Widget videoView = widgets.getPlayer(context, _controller, initPlayer);
    FloatingActionButton btn = widgets.getFab(_controller, () {
      setState(() {
        _controller?.value.isPlaying ?? false
            ? _controller?.pause()
            : _controller?.play();
      });
    });
    return widgets.tabBar(
        context,
        btn,
        videoView,
        vm);
  }
}
