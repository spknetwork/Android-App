import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class PodcastEpisodePlayer extends StatefulWidget {
  const PodcastEpisodePlayer({
    Key? key,
    required this.episode,
    required this.didFinish,
    required this.data,
  });

  final PodcastEpisode episode;
  final Function didFinish;
  final HiveUserData data;

  @override
  State<PodcastEpisodePlayer> createState() => _PodcastEpisodePlayerState();
}

class _PodcastEpisodePlayerState extends State<PodcastEpisodePlayer> {
  List<Widget> _fabButtonsOnRight() {
    return [
      IconButton(
        icon: Icon(Icons.share, color: Colors.blue),
        onPressed: () {
          // _betterPlayerController.pause();
          Share.share(widget.episode.guid ?? '');
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

  Widget actionBar() {
    var duration = widget.episode.duration?.toDouble() ?? 0.0;
    var pending = duration - position;
    var pendingText = "${Utilities.formatTime(pending.toInt())}";
    var leadingText = "${Utilities.formatTime(position.toInt())}";
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 15),
        Text(leadingText),
        Spacer(),
        IconButton(
          icon: Icon(
            play ? Icons.pause : Icons.play_arrow,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() {
              play = !play;
            });
          },
        ),
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
        IconButton(
          icon: Icon(Icons.share, color: Colors.blue),
          onPressed: () {
            // _betterPlayerController.pause();
            Share.share(widget.episode.guid ?? '');
          },
        ),
        Spacer(),
        Text(pendingText),
        SizedBox(width: 15),
      ],
    );
  }

  var play = true;
  var position = 0.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AudioWidget.network(
        url: widget.episode.enclosureUrl ?? '',
        play: play,
        onFinished: () {
          widget.didFinish();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.episode.image ?? ''),
            SizedBox(height: 10),
            Text(
              widget.episode.title ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            Slider(
              value: (position / (widget.episode.duration?.toDouble() ?? 0.0)),
              onChanged: (newValue) {},
            ),
            actionBar(),
          ],
        ),
        onReadyToPlay: (duration) {
          //onReadyToPlay
        },
        onPositionChanged: (current, duration) {
          //onPositionChanged
          setState(() {
            position = current.inSeconds.toDouble();
          });
        },
      ),
    );
  }
}
