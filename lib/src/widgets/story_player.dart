import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/video_detail_favourite_provider.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/hive_comment_dialog.dart';
import 'package:acela/src/screens/video_details_screen/hive_upvote_dialog.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details_info.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

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
  HivePostInfoPostResultBody? postInfo;

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
    loadHiveInfo();
  }

  void loadHiveInfo() async {
    setState(() {
      postInfo = null;
    });
    var data = await fetchHiveInfoForThisVideo(widget.data.rpc);
    setState(() {
      postInfo = data;
    });
  }

  Future<HivePostInfoPostResultBody> fetchHiveInfoForThisVideo(
      String hiveApiUrl) async {
    var request = http.Request('POST', Uri.parse('https://$hiveApiUrl'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {
        "author": widget.item.author?.username ?? 'sagarkothari88',
        "permlink": widget.item.permlink ?? 'ctbtwcxbbd',
        "observer": ""
      }
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) =>
              element.permlink == (widget.item.permlink ?? 'ctbtwcxbbd'))
          .first;
      return result;
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Can not load payout info';
    }
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

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void seeCommentsPressed() {
    _betterPlayerController.pause();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return VideoDetailsComments(
            author: widget.item.author?.username ?? 'sagarkothari88',
            permlink: widget.item.permlink ?? 'ctbtwcxbbd',
            rpc: widget.data.rpc,
          );
        },
      ),
    );
  }

  void upvotePressed() {
    if (postInfo == null) return;
    if (widget.data.username == null) {
      _betterPlayerController.pause();
      showAdaptiveActionSheet(
        context: context,
        title: const Text('You are not logged in. Please log in to upvote.'),
        androidBorderRadius: 30,
        actions: [
          BottomSheetAction(
              title: Text('Log in'),
              leading: Icon(Icons.login),
              onPressed: (c) {
                Navigator.of(c).pop();
                var screen = HiveAuthLoginScreen(appData: widget.data);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(c).push(route);
              }),
        ],
        cancelAction: CancelAction(title: const Text('Cancel')),
      );
      return;
    }
    if (postInfo!.activeVotes
            .map((e) => e.voter)
            .contains(widget.data.username ?? 'sagarkothari88') ==
        true) {
      showError('You have already voted for this 3Shorts');
    }
    _betterPlayerController.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: HiveUpvoteDialog(
            author: widget.item.author?.username ?? 'sagarkothari88',
            permlink: widget.item.permlink ?? 'ctbtwcxbbd',
            username: widget.data.username ?? "",
            hasKey: widget.data.keychainData?.hasId ?? "",
            hasAuthKey: widget.data.keychainData?.hasAuthKey ?? "",
            activeVotes: postInfo!.activeVotes,
            onClose: () {},
            onDone: () {
              loadHiveInfo();
            },
          ),
        );
      },
    );
  }

  void commentPressed() {
    if (postInfo == null) return;
    if (widget.data.username == null) {
      _betterPlayerController.pause();
      showAdaptiveActionSheet(
        context: context,
        title: const Text('You are not logged in. Please log in to comment.'),
        androidBorderRadius: 30,
        actions: [
          BottomSheetAction(
              title: Text('Log in'),
              leading: Icon(Icons.login),
              onPressed: (c) {
                Navigator.of(c).pop();
                var screen = HiveAuthLoginScreen(appData: widget.data);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(c).push(route);
              }),
        ],
        cancelAction: CancelAction(title: const Text('Cancel')),
      );
      return;
    }
    _betterPlayerController.pause();
    var screen = HiveCommentDialog(
      author: widget.item.author?.username ?? 'sagarkothari88',
      permlink: widget.item.permlink ?? 'ctbtwcxbbd',
      username: widget.data.username ?? "",
      hasKey: widget.data.keychainData?.hasId ?? "",
      hasAuthKey: widget.data.keychainData?.hasAuthKey ?? "",
      onClose: () {},
      onDone: () {
        loadHiveInfo();
      },
    );
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => screen));
  }

  List<Widget> _fabButtonsOnRight() {
    final VideoFavoriteProvider provider = VideoFavoriteProvider();
    return [
      FavouriteWidget(
          iconColor: Colors.blue,
          isLiked: provider.isLikedVideoPresentLocally(widget.item,isShorts: true),
          onAdd: () {
            provider.storeLikedVideoLocally(widget.item,isShorts: true);
          },
          onRemove: () {
            provider.storeLikedVideoLocally(widget.item,isShorts: true);
          }),
      IconButton(
        icon: Icon(Icons.share, color: Colors.blue),
        onPressed: () {
          _betterPlayerController.pause();
          Share.share(
              'https://3speak.tv/watch?v=${widget.item.author?.username ?? ''}/${widget.item.permlink ?? ''}');
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.info, color: Colors.blue),
        onPressed: () {
          _betterPlayerController.pause();
          var screen = NewVideoDetailsInfo(
            appData: widget.data,
            item: widget.item,
          );
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ),
      IconButton(
        icon: Icon(Icons.notes, color: Colors.blue),
        onPressed: () {
          seeCommentsPressed();
        },
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.comment, color: Colors.blue),
        onPressed: () {
          commentPressed();
        },
      ),
      SizedBox(height: 10),
      IconButton(
        onPressed: () {
          if (postInfo != null) {
            upvotePressed();
          }
        },
        icon: Icon(Icons.thumb_up, color: Colors.blue),
      ),
      SizedBox(height: 10),
      IconButton(
        icon: Icon(Icons.fullscreen, color: Colors.blue),
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
          url: server
              .userOwnerThumb(widget.item.author?.username ?? 'sagarkothari88'),
        ),
        onPressed: () {
          var screen = UserChannelScreen(
              owner: widget.item.author?.username ?? 'sagarkothari88');
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
                  color: Colors.black54,
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
