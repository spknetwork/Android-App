import 'package:acela/src/widgets/audio_player/action_tools.dart';
import 'package:acela/src/widgets/audio_player/touch_controls.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class NewPodcastEpidosePlayer extends StatefulWidget {
  const NewPodcastEpidosePlayer({Key? key}) : super(key: key);

  @override
  State<NewPodcastEpidosePlayer> createState() => _NewPodcastEpidosePlayerState();
}

class _NewPodcastEpidosePlayerState extends State<NewPodcastEpidosePlayer> {
  final _audioHandler = GetAudioPlayer().audioHandler;

  Stream<Duration> get _bufferedPositionStream => _audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();

  Stream<Duration?> get _durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration).distinct();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  void initState() {
    // _audioHandler.c
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // MediaItem display
            Expanded(
              child: StreamBuilder<MediaItem?>(
                stream: _audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return const SizedBox();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (mediaItem.artUri != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Image.network('${mediaItem.artUri!}'),
                            ),
                          ),
                        ),
                      Text(mediaItem.album ?? '',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(mediaItem.title),
                    ],
                  );
                },
              ),
            ),
            // Playback controls
            ControlButtons(_audioHandler),
            // A seek bar.
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);
                return SeekBar(
                  duration: positionData.duration,
                  position: positionData.position,
                  onChangeEnd: (newPosition) {
                    _audioHandler.seek(newPosition);
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            // Repeat/shuffle controls   // Playlist
          ],
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const ControlButtons(this.audioHandler, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed:
                  queueState.hasPrevious ? audioHandler.skipToPrevious : null,
            );
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: audioHandler.pause,
              );
            }
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
            );
          },
        ),
      ],
    );
  }
}
