import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/stories/stories_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_info.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../screens/user_channel_screen/user_channel_screen.dart';

class StoryPlayer extends StatefulWidget {
  const StoryPlayer({
    Key? key,
    required this.playUrl,
    required this.thumbUrl,
    required this.didFinish,
    required this.item,
    required this.data,
    required this.homeFeedItem,
    required this.isPortrait,
  }) : super(key: key);
  final String playUrl;
  final Function didFinish;
  final StoriesFeedResponseItem? item;
  final HiveUserData data;
  final HomeFeedItem? homeFeedItem;
  final bool isPortrait;
  final String thumbUrl;

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
    // aspectRatio = widget.isPortrait ? 0.5625 : 1.777777778;
    Image(image: NetworkImage(widget.thumbUrl))
        .image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((image, synchronousCall) {
      int width = image.image.width;
      int height = image.image.height;
      debugPrint('Height is - $height, width is - $width');
      debugPrint('Ratio is - ${height > width ? 0.5625 : 1.777777778}');
      setState(() {
        this.width = width.toDouble();
        this.height = height.toDouble();
        aspectRatio = height > width ? 0.5625 : 1.777777778;
        setupPlayer();
      });
    }));
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
      widget.playUrl,
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
          setState(() {
            Share.share(
                'https://3speak.tv/watch?v=${widget.item?.owner ?? widget.homeFeedItem?.author ?? ''}/${widget.item?.permlink ?? widget.homeFeedItem?.permlink ?? ''}');
          });
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.info),
        onPressed: () {
          setState(() {
            // var screen =
            //     VideoDetailsInfoWidget(details: null, item: widget.item);
            // var route = MaterialPageRoute(builder: (c) => screen);
            // Navigator.of(context).push(route);
          });
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.comment),
        onPressed: () {
          setState(() {
            var screen = VideoDetailsComments(
              author: widget.item?.owner ?? widget.homeFeedItem?.author ?? '',
              permlink:
                  widget.item?.permlink ?? widget.homeFeedItem?.permlink ?? '',
              rpc: widget.data.rpc,
            );
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
      // SizedBox(height: 10),
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
      SizedBox(height: 10),
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
            'url': widget.playUrl,
            'seconds': seconds,
          });
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: CustomCircleAvatar(
          height: 40,
          width: 40,
          url: server.userOwnerThumb(
              widget.item?.owner ?? widget.homeFeedItem?.author ?? ''),
        ),
        onPressed: () {
          var screen = UserChannelScreen(
            owner: widget.item?.owner ?? widget.homeFeedItem?.author ?? '',
          );
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
          width == null || height == null
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
