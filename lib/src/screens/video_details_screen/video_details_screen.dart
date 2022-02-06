import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_widgets.dart';
import 'package:flutter/material.dart';
// import 'package:better_player/better_player.dart';

import 'package:video_player/video_player.dart';

class VideoDetailsScreenArguments {
  final HomeFeedItem item;

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
    controller = VideoPlayerController.network(widget.vm.item.playUrl)
      ..initialize().then((_) {
        setState(() {
          controller.play();
        });
      });
    super.initState();
  }

  void initViewModel(BuildContext context) {
    widget.vm.loadVideoInfo(() {
      setState(() {});
    });
    widget.vm.loadComments(widget.vm.item.author, widget.vm.item.permlink, () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    initViewModel(context);
    Widget videoView = widgets.getPlayer(context, controller);
    return widgets.tabBar(context, videoView, widget.vm, () {
      setState(() {});
    });
  }
}
