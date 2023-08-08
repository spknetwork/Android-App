import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details_info.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/user_channel_screen/user_channel_screen.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    required this.didFinish,
    required this.item,
    required this.data,
  }) : super(key: key);
  final GQLFeedItem item;
  final Function didFinish;
  final HiveUserData data;

  @override
  _StoryPlayerState createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<StoryPlayer> {
  late BetterPlayerController _betterPlayerController;

  var aspectRatio = 0.0; // 0.5625
  double? height;
  double? width;

  @override
  void dispose() {
    super.dispose();
    _betterPlayerController.dispose();
  }

  @override
  void initState() {
    super.initState();
    updateRatio();
  }

  void updateRatio() async {
    var ratio = await Communicator().getAspectRatio(widget.item.hlsUrl);
    setState(() {
      aspectRatio = ratio.width / ratio.height;
      setupPlayer();
    });
  }

  void setupPlayer() {
    BetterPlayerConfiguration config = BetterPlayerConfiguration(
      aspectRatio: aspectRatio,
      fit: BoxFit.fitHeight,
      autoPlay: true,
      fullScreenByDefault: false,
      deviceOrientationsOnFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      autoDispose: true,
      expandToFill: true,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        showControls: false,
        showControlsOnInitialize: false,
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
      widget.item.videoV2M3U8(widget.data),
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    setState(() {
      _betterPlayerController = BetterPlayerController(config);
      _betterPlayerController.setupDataSource(dataSource);
    });
  }

  List<Widget> _fabButtonsOnRight() {
    return [
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () {
          Share.share(
              'https://3speak.tv/watch?v=${widget.item.author?.username ?? ''}/${widget.item.permlink ?? ''}');
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          var screen =
          NewVideoDetailsInfo(
            appData: widget.data,
            item: widget.item,
          );
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.comment),
        onPressed: () {
          var screen = VideoDetailsComments(
            author: widget.item.author?.username ?? '',
            permlink: widget.item.permlink ?? '',
            rpc: widget.data.rpc,
          );
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ),
      SizedBox(height: 10),
      // IconButton(
      //   icon: Icon(aspectRatio != 1.777777778
      //       ? Icons.stay_current_landscape
      //       : Icons.stay_current_portrait),
      //   onPressed: () {
      //     _betterPlayerController.pause();
      //     setState(() {
      //       aspectRatio = aspectRatio != 1.777777778 ? 1.777777778 : 0.5625;
      //       setupPlayer();
      //     });
      //   },
      // ),
      // SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.fullscreen),
        onPressed: () async {
          _betterPlayerController.pause();
          var position =
              await _betterPlayerController.videoPlayerController?.position;
          debugPrint('position is $position');
          var seconds = position?.inSeconds;
          if (seconds == null) return;
          const platform = MethodChannel('com.example.acela/auth');
          await platform.invokeMethod('playFullscreen', {
            'url': widget.item.videoV2M3U8(widget.data),
            'seconds': seconds,
          });
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: CustomCircleAvatar(
          height: 40,
          width: 40,
          url: server.userOwnerThumb(widget.item.author?.username ?? 'sagarkothari88'),
        ),
        onPressed: () {
          var screen = UserChannelScreen(owner: widget.item.author?.username ?? 'sagarkothari88');
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ),
      SizedBox(height: 10),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          aspectRatio == 0.0
              ? Center(child: CircularProgressIndicator())
              : BetterPlayer(
                  controller: _betterPlayerController,
                ),
          Row(
            children: [
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _fabButtonsOnRight(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
