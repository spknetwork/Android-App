import 'package:acela/src/global_provider/video_setting_provider.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MuteUnmuteButton extends StatefulWidget {
  const MuteUnmuteButton({required this.betterPlayerController});

  final BetterPlayerController betterPlayerController;

  @override
  State<MuteUnmuteButton> createState() => _MuteUnmuteButtonState();
}

class _MuteUnmuteButtonState extends State<MuteUnmuteButton> {
  @override
  Widget build(BuildContext context) {
    bool isMuted =
        context.select<VideoSettingProvider, bool>((value) => value.isMuted);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isMuted &&
          widget.betterPlayerController.videoPlayerController!.value.volume ==
              0.0) {
        widget.betterPlayerController.setVolume(1);
      } else if (isMuted &&
          widget.betterPlayerController.videoPlayerController!.value.volume !=
              0.0) {
        widget.betterPlayerController.setVolume(0);
      }
    });

    return SizedBox.shrink();
    // IconButton(
    //   icon: Icon(
    //     isMuted ? Icons.volume_off : Icons.volume_up,
    //     color: Colors.white,
    //   ),
    //   onPressed: () {
    //     if (!isMuted) {
    //       widget.betterPlayerController.setVolume(0);
    //     } else {
    //       widget.betterPlayerController.setVolume(1);
    //     }
    //     context.read<VideoSettingProvider>().changeMuteStatus(!isMuted);
    //   },
    // );
  }
}
