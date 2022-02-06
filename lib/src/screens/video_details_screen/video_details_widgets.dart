import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/controls_overlay.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:video_player/video_player.dart';

class VideoDetailsScreenWidgets {
  var showAppBar = true;
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Description'),
    Tab(text: 'Comments')
  ];

  Widget tabBar(
    BuildContext context,
    Widget videoView,
    VideoDetailsViewModel vm,
    Function stateUpdated,
  ) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: showAppBar
                ? AppBar(
                    title: Text(vm.item.title),
                    bottom: const TabBar(tabs: tabs),
                  )
                : null,
            body: TabBarView(
              children: [
                videoView,
                getDescription(context, vm, stateUpdated),
                getComments(context, vm, stateUpdated)
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: showAppBar
                  ? const Icon(Icons.fullscreen)
                  : const Icon(Icons.fullscreen_exit),
              onPressed: () {
                showAppBar = !showAppBar;
                stateUpdated();
              },
            ),
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

  Widget getDescription(
      BuildContext context, VideoDetailsViewModel vm, Function stateUpdated) {
    return vm.descState == LoadState.loading
        ? const LoadingScreen()
        : vm.descState == LoadState.failed
            ? RetryScreen(
                error: vm.descError,
                onRetry: () {
                  vm.descState = LoadState.notStarted;
                  vm.loadVideoInfo(stateUpdated);
                })
            : descriptionMarkDown(vm.description!.description);
  }

  Widget commentsListView(VideoDetailsViewModel vm) {
    return ListView.separated(
        itemBuilder: (context, index) {
          var item = vm.comments[index];
          var userThumb = server.userOwnerThumb(item.author);
          var author = item.author;
          var body = item.body;
          var upVotes = item.activeVotes.where((e) => e.percent > 0).length;
          var downVotes = item.activeVotes.where((e) => e.percent < 0).length;
          var payout = item.pendingPayoutValue.replaceAll(" HBD", "");
          var timeInString = item.createdAt != null
              ? "📆 ${timeago.format(item.createdAt!)}"
              : "";
          var text =
              "👤  $author  👍  $upVotes  👎  $downVotes  💰  $payout  $timeInString";
          var depth = (item.depth * 25.0) - 25;
          double width = MediaQuery.of(context).size.width - 70 - depth;

          return ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: EdgeInsets.only(left: depth)),
                CustomCircleAvatar(height: 25, width: 25, url: userThumb),
                Container(margin: const EdgeInsets.only(right: 10)),
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: body,
                        shrinkWrap: true,
                      ),
                      Container(margin: const EdgeInsets.only(bottom: 10)),
                      Text(
                        text,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                )
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
        itemCount: vm.comments.length);
  }

  Widget getComments(
      BuildContext context, VideoDetailsViewModel vm, Function stateUpdated) {
    return vm.commentsState == LoadState.loading
        ? const LoadingScreen()
        : vm.commentsState == LoadState.failed
            ? RetryScreen(
                error: vm.commentsError,
                onRetry: () {
                  vm.commentsState = LoadState.notStarted;
                  vm.loadComments(
                      vm.item.author, vm.item.permlink, stateUpdated);
                })
            : commentsListView(vm);
  }

  Widget getPlayer(BuildContext context, VideoPlayerController controller) {
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
