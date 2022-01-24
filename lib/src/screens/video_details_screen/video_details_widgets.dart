import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsScreenWidgets {
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Description'),
    Tab(text: 'Comments')
  ];

  Widget tabBar(
    BuildContext context,
    FloatingActionButton fab,
    Widget videoView,
    Widget commentsView,
    VideoDetailsViewModel? vm,
  ) {
    final args = ModalRoute.of(context)!.settings.arguments
        as VideoDetailsScreenArguments;
    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          // final TabController tabController = DefaultTabController.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(args.item.title),
              bottom: const TabBar(tabs: tabs),
            ),
            body: TabBarView(
              children: [videoView, getDescription(context, vm), commentsView],
            ),
            floatingActionButton: fab,
          );
        },
      ),
    );
  }

  Widget descriptionMarkDown(String markDown) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Markdown(
        data: markDown,
        selectable: true,
      ),
    );
  }

  Widget getDescription(BuildContext context, VideoDetailsViewModel? vm) {
    return vm?.descState == LoadState.loading
        ? const LoadingScreen()
        : vm?.descState == LoadState.failed
            ? RetryScreen(
                error: vm?.descError ?? "Something went wrong",
                onRetry: () {
                  vm?.descState = LoadState.notStarted;
                  vm?.loadVideoInfo();
                })
            : descriptionMarkDown(vm!.description!.description);
  }

  Widget getPlayer(BuildContext context, VideoPlayerController? _controller,
      Function(String) initPlayer) {
    final args = ModalRoute.of(context)!.settings.arguments
        as VideoDetailsScreenArguments;
    String url = args.item.ipfs == null
        ? "https://threespeakvideo.b-cdn.net/${args.item.permlink}/default.m3u8"
        : "https://ipfs-3speak.b-cdn.net/ipfs/${args.item.ipfs}/default.m3u8";
    initPlayer(url);
    return Center(
      child: _controller?.value.isInitialized ?? false
          ? VideoPlayer(_controller!)
          : Container(),
    );
  }

  FloatingActionButton getFab(
      VideoPlayerController? _controller, Function() onPressed) {
    return FloatingActionButton(
      onPressed: () {
        onPressed();
      },
      child: Icon(
        _controller?.value.isPlaying ?? false ? Icons.pause : Icons.play_arrow,
      ),
    );
  }
}
