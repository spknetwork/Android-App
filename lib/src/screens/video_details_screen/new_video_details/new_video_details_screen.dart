import 'dart:convert';
import 'dart:io';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/global_provider/video_setting_provider.dart';
import 'package:acela/src/screens/podcast/widgets/favourite.dart';
import 'package:acela/src/screens/trending_tags/trending_tag_videos.dart';
import 'package:acela/src/screens/video_details_screen/comment/hive_comment_dialog.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details/video_detail_favourite_provider.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/hive_upvote_dialog.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details_info.dart';
import 'package:acela/src/screens/video_details_screen/comment/video_details_comments.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/new_feed_list_item.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:better_player/better_player.dart';
import 'package:chip_list/chip_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class NewVideoDetailsScreen extends StatefulWidget {
  const NewVideoDetailsScreen({
    Key? key,
    required this.item,
    required this.appData,
  });

  final GQLFeedItem item;
  final HiveUserData appData;

  @override
  State<NewVideoDetailsScreen> createState() => _NewVideoDetailsScreenState();
}

class _NewVideoDetailsScreenState extends State<NewVideoDetailsScreen> {
  VideoSize? ratio;
  late BetterPlayerController _betterPlayerController;
  HivePostInfoPostResultBody? postInfo;
  var selectedChip = 0;

  List<GQLFeedItem> suggestions = [];

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    loadRatio();
    loadHiveInfo();
    loadSuggestions();
  }

  @override
  void dispose() {
    _betterPlayerController.videoPlayerController!
        .removeListener(_videoPlayerListener);
    super.dispose();
    Wakelock.disable();
  }

  void loadSuggestions() async {
    var items = await GQLCommunicator().getRelated(
      widget.item.author?.username ?? 'sagarkothari88',
      widget.item.permlink ?? 'ctbtwcxbbd',
      widget.appData.language,
    );
    setState(() {
      suggestions = items;
    });
  }

  void loadHiveInfo() async {
    setState(() {
      postInfo = null;
    });
    var data = await fetchHiveInfoForThisVideo(widget.appData.rpc);
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

  void setupVideo(String url, VideoSize size) {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: size.width / size.height,
      fit: BoxFit.contain,
      autoPlay: true,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: false,
        enableFullscreen: false,
        enableSkips: true,
      ),
      autoDetectFullscreenAspectRatio: false,
      autoDetectFullscreenDeviceOrientation: false,
      autoDispose: true,
      expandToFill: true,
      allowedScreenSleep: false,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      Platform.isAndroid
          ? url.replaceAll("/manifest.m3u8", "/480p/index.m3u8")
          : url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  void _videoPlayerListener() {
    final videoSettingProvider = context.read<VideoSettingProvider>();
    if (_betterPlayerController.videoPlayerController != null &&
        _betterPlayerController.videoPlayerController!.value.initialized) {
      if (_betterPlayerController.videoPlayerController!.value.volume == 0.0 &&
          !videoSettingProvider.isMuted) {
        videoSettingProvider.changeMuteStatus(true);
      } else if (_betterPlayerController.videoPlayerController!.value.volume !=
              0.0 &&
          videoSettingProvider.isMuted) {
        videoSettingProvider.changeMuteStatus(false);
      }
    }
  }

  void loadRatio() async {
    final videoSettingProvider = context.read<VideoSettingProvider>();
    var info = await Communicator()
        .getAspectRatio(widget.item.videoV2M3U8(widget.appData));
    setState(() {
      ratio = info;
      setupVideo(widget.item.videoV2M3U8(widget.appData), info);
    });
    if (videoSettingProvider.isMuted) {
      _betterPlayerController.setVolume(0.0);
    }
    _betterPlayerController.videoPlayerController!
        .addListener(_videoPlayerListener);
  }

  void fullscreenTapped() async {
    _betterPlayerController.pause();
    var position =
        await _betterPlayerController.videoPlayerController?.position;
    var seconds = position?.inSeconds;
    if (seconds == null) return;
    debugPrint('position is $position');
    const platform = MethodChannel('com.example.acela/auth');
    await platform.invokeMethod('playFullscreen', {
      'url': widget.item.videoV2M3U8(widget.appData),
      'seconds': seconds,
    });
  }

  Widget _videoPlayerStack(double screenWidth) {
    if (ratio == null) return Container();
    return SizedBox(
      height: (ratio!.height >= ratio!.width)
          ? 460.0
          : (ratio!.height * screenWidth / ratio!.width),
      child: Stack(
        children: [
          BetterPlayer(
            controller: _betterPlayerController,
          ),
          Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      onPressed: () {
                        fullscreenTapped();
                      },
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    String timeInString = widget.item.createdAt != null
        ? "📝 ${timeago.format(widget.item.createdAt!)}"
        : "";
    String durationString = widget.item.spkvideo?.duration != null
        ? " 🕚 ${Utilities.formatTime(widget.item.spkvideo!.duration!.toInt())} "
        : "";
    String votes = "👍 ${widget.item.stats?.numVotes ?? 0}";
    String comments = "💬 ${widget.item.stats?.numComments ?? 0}";
    var subtitle =
        [timeInString, durationString].where((e) => e.isNotEmpty).join(" · ");
    subtitle = "$subtitle\n$votes · $comments";
    return ListTile(
      leading: InkWell(
        child: ClipOval(
          child: CachedImage(
            imageUrl:
                'https://images.hive.blog/u/${widget.item.author?.username ?? 'sagarkothari88'}/avatar',
            imageHeight: 40,
            imageWidth: 40,
          ),
        ),
        onTap: () {
          var screen = UserChannelScreen(
              owner: widget.item.author?.username ?? "sagarkothari88");
          var route = MaterialPageRoute(builder: (_) => screen);
          Navigator.of(context).push(route);
        },
      ),
      title: Text(widget.item.author?.username ?? "sagarkothari88"),
      subtitle: Text(subtitle),
    );
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showVoters() {
    List<String> voters = [];
    bool currentUserPresentInVoters = false;
    if (postInfo != null) {
      if (widget.appData.username != null) {
        int userNameInVotesIndex = postInfo!.activeVotes
            .indexWhere((element) => element.voter == widget.appData.username);
        if (userNameInVotesIndex != -1) {
          currentUserPresentInVoters = true;
          voters.add(widget.appData.username!);
          for (int i = 0; i < postInfo!.activeVotes.length; i++) {
            if (i != userNameInVotesIndex) {
              voters.add(postInfo!.activeVotes[i].voter);
            }
          }
        } else {
          postInfo!.activeVotes.forEach((element) {
            voters.add(element.voter);
          });
        }
      } else {
        postInfo!.activeVotes.forEach((element) {
          voters.add(element.voter);
        });
      }
    }
    postInfo!.activeVotes.forEach((element) {
      print(element.voter);
    });
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            AppBar(
              title: Text("Voters (${voters.length})"),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      upvotePressed();
                    },
                    icon: Icon(
                      Icons.thumb_up_sharp,
                      color: isUserVoted() ? Colors.blue : Colors.grey,
                    ))
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                itemCount: voters.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    minLeadingWidth: 0,
                    dense: true,
                    minVerticalPadding: 0,
                    leading: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            server.userOwnerThumb(voters[index]),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      voters[index],
                      style: TextStyle(
                          color: index == 0 && currentUserPresentInVoters
                              ? Colors.blue
                              : null),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void upvotePressed() {
    if (postInfo == null) return;
    if (widget.appData.username == null) {
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
                var screen = HiveAuthLoginScreen(appData: widget.appData);
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
            .contains(widget.appData.username ?? 'sagarkothari88') ==
        true) {
      showError('You have already voted for this video');
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HiveUpvoteDialog(
          author: widget.item.author?.username ?? 'sagarkothari88',
          permlink: widget.item.permlink ?? 'ctbtwcxbbd',
          username: widget.appData.username ?? "",
          hasKey: widget.appData.keychainData?.hasId ?? "",
          hasAuthKey: widget.appData.keychainData?.hasAuthKey ?? "",
          activeVotes: postInfo!.activeVotes,
          onClose: () {},
          onDone: () {
            loadHiveInfo();
          },
        );
      },
    );
  }

  void infoPressed(double screenWidth) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewVideoDetailsInfo(
            appData: widget.appData,
            item: widget.item,
          ),
        ));
  }

  void seeCommentsPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return VideoDetailsComments(
            author: widget.item.author?.username ?? 'sagarkothari88',
            permlink: widget.item.permlink ?? 'ctbtwcxbbd',
            rpc: widget.appData.rpc,
            appData: widget.appData,
            item: widget.item,
          );
        },
      ),
    );
  }

  Widget _actionBar(double width) {
    final VideoFavoriteProvider provider = VideoFavoriteProvider();
    return ListTile(
      title: Row(
        children: [
          Spacer(),
          IconButton(
            onPressed: () {
              infoPressed(width);
            },
            icon: Icon(Icons.info, color: Colors.blue),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              seeCommentsPressed();
            },
            icon: Icon(Icons.comment, color: Colors.blue),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              if (postInfo != null) {
                showVoters();
              }
            },
            icon: Icon(Icons.thumb_up,
                color: isUserVoted() ? Colors.blue : Colors.grey),
          ),
          Spacer(),
          IconButton(
            onPressed: () {
              Share.share(
                  'https://3speak.tv/watch?v=${widget.item.author?.username ?? 'sagarkothari88'}/${widget.item.permlink}');
            },
            icon: Icon(Icons.share, color: Colors.blue),
          ),
          Spacer(),
          FavouriteWidget(
              toastType: "Video",
              iconColor: Colors.blue,
              isLiked: provider.isLikedVideoPresentLocally(widget.item),
              onAdd: () {
                provider.storeLikedVideoLocally(widget.item);
              },
              onRemove: () {
                provider.storeLikedVideoLocally(widget.item);
              })
        ],
      ),
    );
  }

  bool isUserVoted() {
    if (widget.appData.username != null) {
      if (postInfo != null && postInfo!.activeVotes.isNotEmpty) {
        int index = postInfo!.activeVotes
            .indexWhere((element) => element.voter == widget.appData.username);
        if (index != -1) {
          return true;
        }
      }
    }
    return false;
  }

  Widget _chipList() {
    return ChipList(
      listOfChipNames:
          widget.item.tags ?? ['threespeak', 'video', 'threeshorts'],
      activeBgColorList: [Theme.of(context).primaryColor],
      inactiveBgColorList: [Theme.of(context).primaryColor],
      activeTextColorList: const [Colors.white],
      inactiveTextColorList: const [Colors.white],
      activeBorderColorList: const [Colors.white],
      listOfChipIndicesCurrentlySeclected: [selectedChip],
      extraOnToggle: (selected) {
        var tags = widget.item.tags ?? ['threespeak', 'video', 'threeshorts'];
        var screen = TrendingTagVideos(tag: tags[selected]);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _listView(
    double screenWidth,
  ) {
    if (ratio == null) return Container();
    var height = (ratio!.height >= ratio!.width)
        ? 460.0
        : (ratio!.height * screenWidth / ratio!.width);
    var text = widget.item.spkvideo?.body ?? 'No content';
    if (text.length > 100) {
      text = text.substring(0, 96);
      text = "$text...";
    }
    return ListView.separated(
      itemBuilder: (c, i) {
        if (i == 0) {
          return Container(height: height);
        } else if (i == 1) {
          return ListTile(
            title: Text(widget.item.title ?? 'No title'),
          );
        } else if (i == 2) {
          return _header();
        } else if (i == 3) {
          return _actionBar(screenWidth);
        } else if (i == 4) {
          return _chipList();
        }
        var item = suggestions[i - 5];
        return NewFeedListItem(
          thumbUrl: item.spkvideo?.thumbnailUrl ?? '',
          author: item.author?.username ?? '',
          title: item.title ?? '',
          createdAt: item.createdAt ?? DateTime.now(),
          duration: item.spkvideo?.duration ?? 0.0,
          comments: item.stats?.numComments,
          hiveRewards: item.stats?.totalHiveReward,
          votes: item.stats?.numVotes,
          views: 0,
          permlink: item.permlink ?? '',
          onTap: () {},
          onUserTap: () {},
          item: item,
          appData: widget.appData,
        );
      },
      separatorBuilder: (c, i) =>
          const Divider(height: 0, color: Colors.transparent),
      itemCount: 5 + suggestions.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: ratio == null
            ? LoadingScreen(
                title: 'Loading data',
                subtitle: 'Please wait',
              )
            : Stack(
                children: [
                  _listView(width),
                  _videoPlayerStack(width),
                ],
              ),
      ),
    );
  }
}
