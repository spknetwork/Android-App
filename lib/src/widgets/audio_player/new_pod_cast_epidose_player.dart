import 'dart:async';

import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_info_description.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/download_podcast_button.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/podcast_player_intercation_icon_button.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/audio_player/action_tools.dart';
import 'package:acela/src/widgets/audio_player/touch_controls.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_plus/share_plus.dart';

class NewPodcastEpidosePlayer extends StatefulWidget {
  const NewPodcastEpidosePlayer({Key? key, required this.podcastEpisodes})
      : super(key: key);

  final List<PodcastEpisode> podcastEpisodes;

  @override
  State<NewPodcastEpidosePlayer> createState() =>
      _NewPodcastEpidosePlayerState();
}

class _NewPodcastEpidosePlayerState extends State<NewPodcastEpidosePlayer> {
  final _audioHandler = GetAudioPlayer().audioHandler;
  int currentPodcastIndex = 0;

  late final StreamSubscription queueSubscription;
  late final PodcastController podcastController;
  late PodcastEpisode currentPodcastEpisode;

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
    super.initState();
    podcastController = context.read<PodcastController>();
    currentPodcastEpisode = widget.podcastEpisodes[currentPodcastIndex];
    queueSubscription = _audioHandler.queueState.listen((event) {});
    queueSubscription.onData((data) {
      QueueState queueState = data as QueueState;
      if (currentPodcastIndex != queueState.queueIndex) {
        setState(() {
          currentPodcastIndex = queueState.queueIndex ?? 0;
          currentPodcastEpisode = widget.podcastEpisodes[currentPodcastIndex];
          print(currentPodcastIndex);
        });
      }
    });
  }

  @override
  void dispose() {
    queueSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<MediaItem?>(
          stream: _audioHandler.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;
            if (mediaItem == null) return const SizedBox();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45),
                    child: CachedImage(
                      imageUrl: '${mediaItem.artUri!}',
                      imageHeight: MediaQuery.of(context).size.height * 0.45,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10),
                  child: Text(
                    mediaItem.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                userToolbar(),
                Padding(
                  padding: const EdgeInsets.only(left: 15,right: 15,bottom: 5),
                  child: StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data ??
                          PositionData(
                              Duration.zero, Duration.zero, Duration.zero);
                      var duration =
                          currentPodcastEpisode.duration?.toDouble() ?? 0.0;
                      var pending = duration - positionData.position.inSeconds;
                      var pendingText =
                          "${Utilities.formatTime(pending.toInt())}";
                      var leadingText =
                          "${Utilities.formatTime(positionData.position.inSeconds)}";
                      return Row(
                        children: [
                          Text(leadingText),
                          Expanded(
                            child: SeekBar(
                              duration: positionData.duration,
                              position: positionData.position,
                              onChangeEnd: (newPosition) {
                                _audioHandler.seek(newPosition);
                              },
                            ),
                          ),
                          Text(pendingText),
                        ],
                      );
                    },
                  ),
                ),
                ControlButtons(
                  _audioHandler,
                  podcastEpisode: currentPodcastEpisode,
                  showSkipPreviousButtom: widget.podcastEpisodes.length > 1,
                  positionStream: _positionDataStream.asBroadcastStream(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget userToolbar() {
    Color iconColor = Colors.lightBlue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(Icons.info_outline, color: iconColor),
          onPressed: () {
            _onInfoButtonTap();
          },
        ),
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(Icons.share, color: iconColor),
          onPressed: () {
            Share.share(currentPodcastEpisode.guid ?? '');
          },
        ),
        DownloadPodcastButton(
          color: iconColor,
          episode: currentPodcastEpisode,
        ),
        FavouriteWidget(
            toastType: "Podcast Episode",
            disablePadding: true,
            iconColor: iconColor,
            isLiked: podcastController
                .isLikedPodcastEpisodePresentLocally(currentPodcastEpisode),
            onAdd: () {
              podcastController
                  .storeLikedPodcastEpisodeLocally(currentPodcastEpisode);
            },
            onRemove: () {
              podcastController
                  .storeLikedPodcastEpisodeLocally(currentPodcastEpisode);
            }),
      ],
    );
  }

  void _onInfoButtonTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      isDismissible: true,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: PodcastInfoDescroption(
                title: currentPodcastEpisode.title,
                description: currentPodcastEpisode.description));
      },
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const ControlButtons(this.audioHandler,
      {Key? key,
      required this.showSkipPreviousButtom,
      required this.podcastEpisode,
      required this.positionStream})
      : super(key: key);

  final bool showSkipPreviousButtom;
  final PodcastEpisode podcastEpisode;
  final Stream<PositionData> positionStream;

  @override
  Widget build(BuildContext context) {
    Color iconColor = Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          visible: showSkipPreviousButtom,
          child: StreamBuilder<QueueState>(
            stream: audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;
              return IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: queueState.hasPrevious
                      ? iconColor
                      : iconColor.withOpacity(0.5),
                ),
                onPressed:
                    queueState.hasPrevious ? audioHandler.skipToPrevious : null,
              );
            },
          ),
        ),
        StreamBuilder<PositionData>(
          stream: positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ??
                PositionData(Duration.zero, Duration.zero, Duration.zero);
            return PodcastPlayerInteractionIconButton(
                size: 30,
                horizontalPadding: 20,
                onPressed: () {
                  if (positionData.position.inSeconds > 10) {
                    audioHandler.seek(Duration(
                        seconds: positionData.position.inSeconds - 10));
                  } else {
                    audioHandler.seek(Duration(seconds: 0));
                  }
                },
                icon: Icons.replay_10,
                color: iconColor);
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.idle)
              audioHandler.play();
            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return SizedBox(
                width: 40.0,
                height: 40.0,
                child: const CircularProgressIndicator(strokeWidth: 2.5,),
              );
            } else if (playing != true) {
              return GestureDetector(
                onTap: audioHandler.play,
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.play_arrow,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: audioHandler.pause,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.pause,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              );
            }
          },
        ),
        StreamBuilder<PositionData>(
          stream: positionStream,
          builder: (context, snapshot) {
            final positionData = snapshot.data ??
                PositionData(Duration.zero, Duration.zero, Duration.zero);
            return PodcastPlayerInteractionIconButton(
                size: 30,
                horizontalPadding: 20,
                onPressed: () {
                  audioHandler.seek(
                      Duration(seconds: positionData.position.inSeconds + 10));
                },
                icon: Icons.forward_10,
                color: iconColor);
          },
        ),
        Visibility(
          visible: showSkipPreviousButtom,
          child: StreamBuilder<QueueState>(
            stream: audioHandler.queueState,
            builder: (context, snapshot) {
              final queueState = snapshot.data ?? QueueState.empty;
              return IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: queueState.hasNext
                      ? iconColor
                      : iconColor.withOpacity(0.5),
                ),
                onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
