import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_info_description.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/download_podcast_button.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/podcast_player_intercation_icon_button.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class PodcastEpisodePlayer extends StatefulWidget {
  const PodcastEpisodePlayer(
      {Key? key,
      required this.data,
      required this.podcastEpisodes,
      this.episodeIndex});

  final List<PodcastEpisode> podcastEpisodes;
  final HiveUserData data;
  final int? episodeIndex;

  @override
  State<PodcastEpisodePlayer> createState() => _PodcastEpisodePlayerState();
}

class _PodcastEpisodePlayerState extends State<PodcastEpisodePlayer> {
  late final PodcastController podcastController;
  late PodcastEpisode curentPodcastEpisode;
  int currentPodcastEpisodeIndex = 0;
  var play = true;
  var position = 0.0;
  int initialPosition = 0;

  @override
  void initState() {
    super.initState();
    if (widget.episodeIndex != null) {
      currentPodcastEpisodeIndex = widget.episodeIndex!;
    }
    curentPodcastEpisode = widget.podcastEpisodes[currentPodcastEpisodeIndex];
    podcastController = context.read<PodcastController>();
  }

  List<Widget> _fabButtonsOnRight() {
    return [
      IconButton(
        icon: Icon(Icons.share, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          Share.share(curentPodcastEpisode.guid ?? '');
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.info, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          // var screen =
          // NewVideoDetailsInfo(
          //   appData: widget.data,
          //   item: widget.item,
          // );
          // var route = MaterialPageRoute(builder: (c) => screen);
          // Navigator.of(context).push(route);
        },
      ),
      SizedBox(height: 10),
    ];
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
            // _betterPlayerController.pause();
            // var screen =
            // NewVideoDetailsInfo(
            //   appData: widget.data,
            //   item: widget.item,
            // );
            // var route = MaterialPageRoute(builder: (c) => screen);
            // Navigator.of(context).push(route);
          },
        ),
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(Icons.share, color: iconColor),
          onPressed: () {
            // _betterPlayerController.pause();
            Share.share(curentPodcastEpisode.guid ?? '');
          },
        ),
        DownloadPodcastButton(
          color: iconColor,
          episode: curentPodcastEpisode,
        ),
        FavouriteWidget(
          toastType: "Podcast Episode",
            disablePadding: true,
            iconColor: iconColor,
            isLiked: podcastController
                .isLikedPodcastEpisodePresentLocally(curentPodcastEpisode),
            onAdd: () {
              podcastController
                  .storeLikedPodcastEpisodeLocally(curentPodcastEpisode);
            },
            onRemove: () {
              podcastController
                  .storeLikedPodcastEpisodeLocally(curentPodcastEpisode);
            }),
      ],
    );
  }

  Widget actionBar() {
    Color iconColor = Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: widget.podcastEpisodes.length > 1,
            child: PodcastPlayerInteractionIconButton(
              onPressed: _playPrevious,
              icon: Icons.skip_previous,
              color: currentPodcastEpisodeIndex == 0
                  ? iconColor.withOpacity(0.5)
                  : iconColor,
            )),
        PodcastPlayerInteractionIconButton(
            horizontalPadding: 20,
            onPressed: _reverseTenSeconds,
            size: 30,
            icon: Icons.replay_10,
            color: iconColor),
        GestureDetector(
          onTap: _pausePlayer,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              play ? Icons.pause : Icons.play_arrow,
              size: 30,
              color: Colors.black,
            ),
          ),
        ),
        PodcastPlayerInteractionIconButton(
            size: 30,
            horizontalPadding: 20,
            onPressed: _forwardTenSeconds,
            icon: Icons.forward_10,
            color: iconColor),
        Visibility(
            visible: widget.podcastEpisodes.length > 1,
            child: PodcastPlayerInteractionIconButton(
              onPressed: _playNext,
              icon: Icons.skip_next,
              color: currentPodcastEpisodeIndex ==
                      widget.podcastEpisodes.length - 1
                  ? iconColor.withOpacity(0.5)
                  : iconColor,
            )),
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
                title: curentPodcastEpisode.title,
                description: curentPodcastEpisode.description));
      },
    );
  }

  void _pausePlayer() {
    setState(() {
      play = !play;
    });
  }

  void _playNext() {
    if (currentPodcastEpisodeIndex != widget.podcastEpisodes.length - 1) {
      setState(() {
        position = 0;
        currentPodcastEpisodeIndex++;
        curentPodcastEpisode =
            widget.podcastEpisodes[currentPodcastEpisodeIndex];
        initialPosition = 0;
        play = true;
      });
    }
  }

  void _playPrevious() {
    if (currentPodcastEpisodeIndex != 0) {
      setState(() {
        --currentPodcastEpisodeIndex;
        curentPodcastEpisode =
            widget.podcastEpisodes[currentPodcastEpisodeIndex];
        initialPosition = 0;
        play = true;
      });
    }
  }

  void _forwardTenSeconds() {
    setState(() {
      int episodeDuration = curentPodcastEpisode.duration ?? 0;
      initialPosition = (position + 10).toInt().clamp(0, episodeDuration);
      if (initialPosition == episodeDuration) {
        _playNext();
      }
    });
  }

  void _reverseTenSeconds() {
    setState(() {
      initialPosition =
          (position - 10).toInt().clamp(0, curentPodcastEpisode.duration ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          play = false;
        });
        return true;
      },
      child: SafeArea(child: _playerStatus()),
    );
  }

  Widget _playerStatus() {
    if (context.read<PodcastController>().isOffline(
        curentPodcastEpisode.enclosureUrl ?? "",
        curentPodcastEpisode.id.toString())) {
      return AudioWidget.file(
          initialPosition: Duration(seconds: initialPosition),
          path: podcastController.getOfflineUrl(
              curentPodcastEpisode.enclosureUrl ?? "",
              curentPodcastEpisode.id.toString()),
          play: play,
          // onFinished: _playNext,
          child: child(context),
          onReadyToPlay: (duration) {
            //onReadyToPlay
          },
          onPositionChanged: _onPositionChanged);
    } else {
      return AudioWidget.network(
          initialPosition: Duration(seconds: initialPosition),
          url: curentPodcastEpisode.enclosureUrl ?? '',
          play: play,
          // onFinished: _playNext,
          child: child(context),
          onReadyToPlay: (duration) {
            //onReadyToPlay
          },
          onPositionChanged: _onPositionChanged);
    }
  }

  void _onPositionChanged(Duration current, Duration duration) {
    setState(() {
      position = current.inSeconds.toDouble();
    });
    if (position != 0) {
      int episodeDuration = curentPodcastEpisode.duration ?? 0;
      if (position == episodeDuration) {
        _playNext();
      }
    }
  }

  Column child(BuildContext context) {
    var duration = curentPodcastEpisode.duration?.toDouble() ?? 0.0;
    var pending = duration - position;
    var pendingText = "${Utilities.formatTime(pending.toInt())}";
    var leadingText = "${Utilities.formatTime(position.toInt())}";
    double min = 0;
    double max = curentPodcastEpisode.duration?.toDouble() ?? 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45),
            child: Image.network(curentPodcastEpisode.image ?? '')),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
          child: Text(
            curentPodcastEpisode.title ?? '',
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        userToolbar(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text(leadingText),
              Expanded(
                child: Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white38,
                  min: min,
                  max: max,
                  value: (position.clamp(min, max)),
                  onChanged: (newValue) {
                    setState(() {
                      position = newValue;
                      initialPosition = newValue.toInt();
                    });
                  },
                ),
              ),
              Text(pendingText),
            ],
          ),
        ),
        actionBar(),
      ],
    );
  }
}
