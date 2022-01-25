import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
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
              children: [
                videoView,
                getDescription(context, vm),
                getComments(context, vm)
              ],
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

  Widget commentsListView(VideoDetailsViewModel? vm) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: ListView.separated(
            itemBuilder: (context, index) {
              var item = vm!.comments[index];
              var userThumb = server.userOwnerThumb(item.author);
              var author = item.author;
              var body = item.body;
              var upVotes = item.activeVotes.where((e) => e.percent > 0).length;
              var downVotes = item.activeVotes.where((e) => e.percent < 0).length;
              var payout = item.pendingPayoutValue.replaceAll(" HBD", "");
              var text = "👤  $author  👍  $upVotes  👎  $downVotes  💰  $payout";
              return ListTile(
                leading: CustomCircleAvatar(
                  height: 50,
                  width: 50,
                  url: userThumb,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: body,
                    ),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ],
                ),
                onTap: () {
                  print("Tapped");
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(
                  height: 10,
                  color: Colors.blueGrey,
                ),
            itemCount: vm!.comments.length));
  }

  Widget getComments(BuildContext context, VideoDetailsViewModel? vm) {
    return vm?.commentsState == LoadState.loading
        ? const LoadingScreen()
        : vm?.commentsState == LoadState.failed
            ? RetryScreen(
                error: vm?.commentsError ?? "Something went wrong",
                onRetry: () {
                  vm?.commentsState = LoadState.notStarted;
                  vm?.loadComments(vm.item.owner, vm.item.permlink);
                })
            : commentsListView(vm);
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
