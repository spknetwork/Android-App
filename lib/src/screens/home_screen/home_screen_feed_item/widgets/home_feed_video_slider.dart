import 'package:acela/src/screens/home_screen/home_screen_feed_item/controller/home_feed_video_controller.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeFeedVideoSlider extends StatelessWidget {
  const HomeFeedVideoSlider({Key? key, required this.betterPlayerController})
      : super(key: key);
  final BetterPlayerController? betterPlayerController;

  @override
  Widget build(BuildContext context) {
    double min = 0;
    bool isInitialized = context
        .select<HomeFeedVideoController, bool>((value) => value.isInitialized);
    Duration? currentDuration =
        context.select<HomeFeedVideoController, Duration?>(
            (value) => value.currentDuration);
    Duration? totalDuration =
        context.select<HomeFeedVideoController, Duration?>(
            (value) => value.totalDuration);
    return isInitialized && totalDuration != null && currentDuration != null
        ? SliderTheme(
            data: SliderThemeData(
              trackHeight: 2.0, 
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0.0),
              trackShape: RectangularSliderTrackShape(),
            ),
            child: Slider(
              activeColor: Colors.white,
              inactiveColor: Colors.white38,
              min: min,
              max: Utilities.durationToDouble(totalDuration),
              value: (Utilities.durationToDouble(currentDuration)
                  .clamp(min, Utilities.durationToDouble(totalDuration))),
              onChanged: (newValue) {
                betterPlayerController!.seekTo(Utilities.doubleToDuration(newValue)).then(
                    (value) =>
                        betterPlayerController!.videoPlayerController!.play());
              },
            ),
          )
        : const SizedBox.shrink();
  }


}
