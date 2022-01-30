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
  const VideoDetailsScreen({Key? key, required this.vm}) : super(key: key);
  final VideoDetailsViewModel vm;

  static const routeName = '/video_details';

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  final widgets = VideoDetailsScreenWidgets();
  late VideoPlayerController controller;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    String url = widget.vm.item.ipfs == null
        ? "https://threespeakvideo.b-cdn.net/${widget.vm.item.permlink}/default.m3u8"
        : "https://ipfs-3speak.b-cdn.net/ipfs/${widget.vm.item.ipfs}/default.m3u8";
    controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
    super.initState();
  }

  Widget videoPlayer() {
    return Center(
      child: controller.value.isInitialized
          ? VideoPlayer(controller)
          : Container(),
    );
  }

  void initViewModel(BuildContext context) {
    widget.vm.loadVideoInfo(() {
      setState(() {});
    });
    widget.vm.loadComments(widget.vm.item.owner, widget.vm.item.permlink,() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    initViewModel(context);
    Widget videoView = videoPlayer();
    FloatingActionButton btn = widgets.getFab(controller, () {
      setState(() {
        controller.value.isPlaying
            ? controller.pause()
            : controller.play();
      });
    });
    return widgets.tabBar(context, btn, videoView, widget.vm, () {
      setState(() {});
    });
  }
}
