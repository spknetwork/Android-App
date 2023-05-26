import 'dart:developer';

import 'package:acela/src/models/stories/stories_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_info.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    required this.playUrl,
    required this.didFinish,
    required this.item,
    required this.data,
  }) : super(key: key);
  final String playUrl;
  final Function didFinish;
  final StoriesFeedResponseItem item;
  final HiveUserData data;

  @override
  _StoryPlayerState createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerConfiguration config;

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  @override
  void initState() {
    config = BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.fitHeight,
      autoPlay: true,
      fullScreenByDefault: false,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      autoDispose: true,
      expandToFill: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: true,
        showControlsOnInitialize: true,
        enableFullscreen: false,
      ),
      showPlaceholderUntilPlay: true,
      allowedScreenSleep: false,
      eventListener: (event) {
        log('type - ${event.betterPlayerEventType.toString()}');
        if (event.betterPlayerEventType == BetterPlayerEventType.finished) {
          widget.didFinish();
        }
      },
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.playUrl,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(config);
    _betterPlayerController.setupDataSource(dataSource);
    super.initState();
  }

  ButtonStyle _style() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
    );
  }

  List<Widget> _fabButtonsOnRight() {
    return [
      const Spacer(),
      ElevatedButton(
        child: Icon(Icons.share),
        style: _style(),
        onPressed: () {
          setState(() {
            Share.share(
                'https://3speak.tv/watch?v=${widget.item.owner}/${widget.item.permlink}');
          });
        },
      ),
      SizedBox(height: 10),
      ElevatedButton(
        style: _style(),
        child: Icon(Icons.info),
        onPressed: () {
          setState(() {
            var screen =
                VideoDetailsInfoWidget(details: null, item: widget.item);
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
      SizedBox(height: 10),
      ElevatedButton(
        style: _style(),
        child: Icon(Icons.comment),
        onPressed: () {
          setState(() {
            var screen = VideoDetailsComments(
              author: widget.item.owner,
              permlink: widget.item.permlink,
              rpc: widget.data.rpc,
            );
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
      SizedBox(height: 10),
      ElevatedButton(
        style: _style(),
        child: Icon(Icons.fullscreen),
        onPressed: () {
          setState(() {});
        },
      ),
      const Spacer(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      BetterPlayer(
        controller: _betterPlayerController,
      ),
      Row(children: [
        const Spacer(),
        Column(
          children: _fabButtonsOnRight(),
        ),
      ]),
    ]);
  }
}
