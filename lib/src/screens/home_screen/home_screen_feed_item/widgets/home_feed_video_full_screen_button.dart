import 'package:acela/src/screens/home_screen/home_screen_feed_item/controller/home_feed_video_controller.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeFeedVideoFullScreenButton extends StatelessWidget {
  const HomeFeedVideoFullScreenButton(
      {Key? key, required this.betterPlayerController})
      : super(key: key);

  final BetterPlayerController betterPlayerController;

  @override
  Widget build(BuildContext context) {
    bool isInitialized = context
        .select<HomeFeedVideoController, bool>((value) => value.isInitialized);
    return Visibility(
      visible: isInitialized,
      child: IconButton(
          onPressed: () {
            context
                .read<HomeFeedVideoController>()
                .changeControlsVisibility(betterPlayerController, true);
            betterPlayerController.enterFullScreen();
          },
          icon: Icon(Icons.fullscreen)),
    );
  }
}
