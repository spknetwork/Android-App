import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_widgets.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';

// import 'package:video_player/video_player.dart';

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
  // late VideoPlayerController controller;
  late BetterPlayerController _betterPlayerController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    String url = widget.vm.item.ipfs == null
        ? "https://threespeakvideo.b-cdn.net/${widget.vm.item.permlink}/default.m3u8"
        : "https://ipfs-3speak.b-cdn.net/ipfs/${widget.vm.item.ipfs}/default.m3u8";
    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        url);
    _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(),
        betterPlayerDataSource: betterPlayerDataSource);
    // controller = VideoPlayerController.network(url)
    //   ..initialize().then((_) {
    //     setState(() {
    //       controller.play();
    //     });
    //   });
    super.initState();
  }

  Widget videoPlayer() {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(
          controller: _betterPlayerController,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return widgets.tabBar(
        context,
        videoPlayer(),
        widget.vm,
    );
  }
}
