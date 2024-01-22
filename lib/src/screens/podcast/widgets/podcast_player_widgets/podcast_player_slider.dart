import 'package:acela/src/screens/podcast/controller/podcast_chapters_controller.dart';
import 'package:acela/src/screens/podcast/widgets/audio_player/action_tools.dart';
import 'package:acela/src/screens/podcast/widgets/audio_player/audio_player_core_controls.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:flutter/material.dart';

class PodcastPlayerSlider extends StatelessWidget {
  const PodcastPlayerSlider(
      {Key? key,
      required this.chapterController,
      required this.audioPlayerHandler,
      required this.currentPodcastEpisodeDuration, required this.positionDataStream})
      : super(key: key);

  final PodcastChapterController chapterController;
  final AudioPlayerHandler audioPlayerHandler;
  final int? currentPodcastEpisodeDuration;
  final Stream<PositionData> positionDataStream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
      child: StreamBuilder<PositionData>(
        stream: positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data ??
              PositionData(Duration.zero, Duration.zero, Duration.zero);
          var duration = currentPodcastEpisodeDuration?.toDouble() ?? 0.0;
          var pending = duration - positionData.position.inSeconds;
          var pendingText = "${Utilities.formatTime(pending.toInt())}";
          var leadingText =
              "${Utilities.formatTime(positionData.position.inSeconds)}";
          chapterController.setDurationData(positionData);
          chapterController.syncChapters();
          return Row(
            children: [
              Text(leadingText),
              Expanded(
                child: SeekBar(
                  duration: positionData.duration,
                  position: positionData.position,
                  onChanged: _onSlideChange,
                  onChangeEnd: (newPosition) {
                    audioPlayerHandler.seek(newPosition);
                  },
                ),
              ),
              Text(pendingText),
            ],
          );
        },
      ),
    );
  }

  void _onSlideChange(Duration newPosition) {
    chapterController.syncChapters(
        isInteracted: true,
        isReduced: newPosition.inSeconds < chapterController.currentDuration);
    chapterController.currentDuration = newPosition.inSeconds;
    audioPlayerHandler.seek(newPosition);
  }
}
