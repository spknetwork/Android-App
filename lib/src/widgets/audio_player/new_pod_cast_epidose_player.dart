import 'dart:async';
import 'dart:developer';

import 'package:acela/src/models/podcast/podcast_episode_chapters.dart';
import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_info_description.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/download_podcast_button.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/podcast_player_intercation_icon_button.dart';
import 'package:acela/src/screens/podcast/widgets/value_for_value_view.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/audio_player/action_tools.dart';
import 'package:acela/src/widgets/audio_player/touch_controls.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
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
  List<PodcastEpisodeChapter>? chapters;
  late String title;
  late String? imageUrl;
  int currentDuration = 0;
  late int totalDuration;

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
    imageUrl = currentPodcastEpisode.image;
    title = currentPodcastEpisode.title!;
    totalDuration = currentPodcastEpisode.duration ?? 0;
    print('chapters url');
    print(currentPodcastEpisode.chaptersUrl);
    loadChapters();
    queueSubscription = _audioHandler.queueState.listen((event) {});
    queueSubscription.onData((data) {
      QueueState queueState = data as QueueState;
      if (currentPodcastIndex != queueState.queueIndex) {
        setState(() {
          currentPodcastIndex = queueState.queueIndex ?? 0;
          currentPodcastEpisode = widget.podcastEpisodes[currentPodcastIndex];
          title = currentPodcastEpisode.title!;
          imageUrl = currentPodcastEpisode.image;
          print(currentPodcastIndex);
        });
      }
    });
  }

  void loadChapters() async {
    if (currentPodcastEpisode.chaptersUrl != null) {
      var result = await PodCastCommunicator()
          .getPodcastEpisodeChapters(currentPodcastEpisode.chaptersUrl!);
      result.removeWhere((element) => element.toc != null);
      setState(() {
        chapters = result;
      });
    } else {
      chapters = null;
    }
  }

  void jumpToNextChapter(Function callback) {
    if (chapters != null && chapters!.isNotEmpty) {
      int index = chapters!.indexWhere((element) {
        return element.startTime! > currentDuration;
      });
      if (index != -1) {
        setChapterTitleAndImage(index);
        int startTime = chapters![index].startTime!;
        if (startTime > totalDuration) {
          callback();
        } else {
          _audioHandler.seek(Duration(seconds: startTime));
        }
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  void jumpToPreviousChapter(Function callback) {
    if (chapters != null && chapters!.isNotEmpty) {
      int? index = findNearestLessThan(checkEqual: false);
      if (index != null) {
        setChapterTitleAndImage(index);
        int startTime = chapters![index].startTime!;
        if (startTime < 0) {
          callback();
        } else {
          _audioHandler.seek(Duration(seconds: startTime));
        }
      } else {
        callback();
      }
    } else {
      callback();
    }
  }

  bool hasPreviousChapter() {
    if (chapters != null && chapters!.isNotEmpty) {
      int? index = findNearestLessThan(checkEqual: false);
      log(index.toString());
      if (index == 0 && currentDuration == 0) {
        return false;
      } else {
        return index != null;
      }
    }
    return false;
  }

  bool hasNextChapter() {
    if (chapters != null && chapters!.isNotEmpty) {
      int index = chapters!.indexWhere((element) {
        return element.startTime! > currentDuration;
      });
      return index != -1;
    }
    return false;
  }

  void syncChapters({bool isInteracted = false, bool isReduced = false}) {
    if (chapters != null && chapters!.isNotEmpty) {
      if (!isInteracted) {
        int index = chapters!
            .indexWhere((element) => element.startTime == currentDuration);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setChapterTitleAndImage(index);
        });
      } else {
        if (!isReduced) {
          int index = chapters!
              .indexWhere((element) => element.startTime == currentDuration);
          if (index == -1) {
            int newIndex = chapters!.indexWhere((element) {
              return element.startTime! > currentDuration;
            });
            if ((newIndex - 1 > 0)) {
              setChapterTitleAndImage(newIndex - 1);
            } else {
              setChapterTitleAndImage(0);
            }
          } else {
            setChapterTitleAndImage(index);
          }
        } else {
          if (isReduced) {
            int? index = findNearestLessThan();
            if (index != null) {
              setChapterTitleAndImage(index);
            }
          }
        }
      }
    }
  }

  int? findNearestLessThan({bool checkEqual = true}) {
    int? result;
    for (int i = 0; i < chapters!.length; i++) {
      if (checkEqual) {
        if (chapters![i].startTime == currentDuration) {
          return i;
        }
      }
      if (chapters![i].startTime! < currentDuration) {
        result = i;
      } else {
        return result;
      }
    }
    return result;
  }

  void setChapterTitleAndImage(int index) {
    if (index != -1 && index < chapters!.length) {
      setState(() {
        String? chapterTitle = chapters![index].title;
        String? chapterImage = chapters![index].image;
        if (chapterTitle != null) {
          title = chapterTitle;
        }
        if (chapterImage != null) {
          imageUrl = chapterImage;
        }
      });
    }
  }

  void previousChapter() {}

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
                      imageUrl: imageUrl,
                      imageHeight: MediaQuery.of(context).size.height * 0.45,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // Text(
                      //   timeago.format(
                      //     DateTime.parse(
                      //         currentPodcastEpisode.datePublishedPretty!),
                      //   ),
                      // ),
                      Text(
                        currentPodcastEpisode.datePublishedPretty.toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                userToolbar(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                  child: StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data ??
                          PositionData(
                              Duration.zero, Duration.zero, Duration.zero);
                      var duration =
                          currentPodcastEpisode.duration?.toDouble() ?? 0.0;
                      print(duration);
                      var pending = duration - positionData.position.inSeconds;
                      var pendingText =
                          "${Utilities.formatTime(pending.toInt())}";
                      var leadingText =
                          "${Utilities.formatTime(positionData.position.inSeconds)}";
                      currentDuration = positionData.position.inSeconds;
                      totalDuration = positionData.duration.inSeconds;
                      // print(positionData.position.inSeconds);
                      syncChapters();
                      return Row(
                        children: [
                          Text(leadingText),
                          Expanded(
                            child: SeekBar(
                              duration: positionData.duration,
                              position: positionData.position,
                              onChanged: (newPosition) {
                                syncChapters(
                                    isInteracted: true,
                                    isReduced: newPosition.inSeconds <
                                        currentDuration);
                                currentDuration = newPosition.inSeconds;
                                // print('currentDuration &currentDuration');

                                _audioHandler.seek(newPosition);
                              },
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
                  chapterSyncCallback: (isReduced) {
                    if (isReduced) {
                      if (currentDuration - 10 < 0) {
                        currentDuration = 0;
                      } else {
                        currentDuration = currentDuration - 10;
                      }
                    } else {
                      currentDuration = currentDuration + 10;
                    }
                    syncChapters(isInteracted: true, isReduced: isReduced);
                  },
                  onNext: (playNextEpisode) {
                    jumpToNextChapter(
                        playNextEpisode != null ? playNextEpisode() : () {});
                  },
                  onPrevious: (playPreviousEpisode) {
                    jumpToPreviousChapter(playPreviousEpisode != null
                        ? playPreviousEpisode()
                        : () {});
                  },
                  hasPreviousChapter: hasPreviousChapter(),
                  hasNextChapter: hasNextChapter(),
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
    List<Widget> tools = [
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
          Share.share(currentPodcastEpisode.enclosureUrl ?? '');
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
      IconButton(
        onPressed: () {
          _onTapPodcastHistory();
        },
        icon: Icon(
          Icons.list,
          color: iconColor,
        ),
      )
    ];
    if (context.read<HiveUserData>().username != null) {
      tools.insert(
        3,
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(CupertinoIcons.gift_fill, color: iconColor),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ValueForValueView(),
            ));
          },
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tools,
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

  void _onTapPodcastHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      isDismissible: true,
      builder: (context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: widget.podcastEpisodes.length,
              itemBuilder: (context, index) {
                PodcastEpisode item = widget.podcastEpisodes[index];
                return ListTile(
                  onTap: () {
                    _audioHandler.skipToQueueItem(index);
                    setState(() {
                      currentPodcastIndex = index;
                      currentPodcastEpisode = item;
                      Navigator.pop(context);
                    });
                  },
                  trailing: Icon(Icons.play_circle_outline_outlined),
                  leading: CachedImage(
                    imageUrl: item.image,
                    imageHeight: 48,
                    imageWidth: 48,
                    loadingIndicatorSize: 25,
                  ),
                  title: Text(
                    item.title!,
                    style: TextStyle(fontSize: 14),
                  ),
                );
              },
            ));
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
      required this.positionStream,
      required this.chapterSyncCallback,
      required this.onNext,
      required this.onPrevious,
      required this.hasPreviousChapter,
      required this.hasNextChapter})
      : super(key: key);

  final bool showSkipPreviousButtom;
  final PodcastEpisode podcastEpisode;
  final Stream<PositionData> positionStream;
  final Function(bool isReduced) chapterSyncCallback;
  final Function(Function?) onNext;
  final Function(Function?) onPrevious;
  final bool hasPreviousChapter;
  final bool hasNextChapter;

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
                  color: hasPreviousChapter || queueState.hasPrevious
                      ? iconColor
                      : iconColor.withOpacity(0.5),
                ),
                onPressed: () {
                  onPrevious(() {
                    return queueState.hasPrevious
                        ? audioHandler.skipToPrevious
                        : () {};
                  });
                },
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
                  chapterSyncCallback(true);
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
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
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
                  chapterSyncCallback(false);
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
                  color: hasNextChapter || queueState.hasNext
                      ? iconColor
                      : iconColor.withOpacity(0.5),
                ),
                onPressed: () {
                  onNext(() {
                    return queueState.hasNext ? audioHandler.skipToNext : () {};
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
