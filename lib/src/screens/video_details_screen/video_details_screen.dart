import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_recommendation_models/video_recommendation.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/hive_comment_dialog.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_info.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/full_screen_video_player.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/video_player.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'hive_upvote_dialog.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({Key? key, required this.vm}) : super(key: key);
  final VideoDetailsViewModel vm;

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late Future<List<VideoRecommendationItem>> recommendedVideos;
  Future<List<HiveComment>>? _loadComments;

  Future<HivePostInfoPostResultBody>? _fetchHiveInfoForThisVideo;

  @override
  void initState() {
    super.initState();
    recommendedVideos = widget.vm.getRecommendedVideos();
  }

  void onUserTap() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => UserChannelScreen(owner: widget.vm.author)));
  }

  // used when there is an error state in loading video info
  Widget container(String title, Widget body) {
    return Scaffold(
      body: body,
      appBar: AppBar(
        title: Text(title),
      ),
    );
  }

  //region Video Info
  // video description
  Widget descriptionMarkDown(String markDown) {
    return Markdown(
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  // fetch hive info
  Future<HivePostInfoPostResultBody> fetchHiveInfoForThisVideo(
      String hiveApiUrl) async {
    var request = http.Request('POST', Uri.parse('https://$hiveApiUrl'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {
        "author": widget.vm.author,
        "permlink": widget.vm.permlink,
        "observer": ""
      }
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == widget.vm.permlink)
          .first;
      return result;
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Can not load payout info';
    }
  }

  // video description
  Widget titleAndSubtitle(VideoDetails details, HiveUserData appData) {
    return FutureBuilder(
      future: _fetchHiveInfoForThisVideo,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading hive payout info');
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          String string =
              "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
          var data = snapshot.data as HivePostInfoPostResultBody;
          var upVotes = data.activeVotes.where((e) => e.rshares > 0).length;
          var downVotes = data.activeVotes.where((e) => e.rshares < 0).length;
          String priceAndVotes =
              "\$ ${data.payout.toStringAsFixed(3)} · 👍 $upVotes · 👎 $downVotes";
          return Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                InkWell(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(details.title,
                                style: Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 3),
                            Text(string,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 3),
                            Text(priceAndVotes,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down_outlined),
                    ],
                  ),
                  onTap: () {
                    showModalForDescription(details);
                  },
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      child: CustomCircleAvatar(
                          height: 40,
                          width: 40,
                          url: server.userOwnerThumb(details.owner)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (c) =>
                                UserChannelScreen(owner: details.owner),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    InkWell(
                        child: Text(details.owner,
                            style: Theme.of(context).textTheme.bodyLarge),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (c) =>
                                  UserChannelScreen(owner: details.owner),
                            ),
                          );
                        }),
                    SizedBox(width: 10),
                    Spacer(),
                    IconButton(
                      onPressed: () async {
                        _betterPlayerController.pause();
                        var position = await _betterPlayerController.videoPlayerController?.position;
                        var seconds = position?.inSeconds ;
                        if (seconds == null) return;
                        debugPrint('position is $position');
                        const platform = MethodChannel('com.example.acela/auth');
                        await platform.invokeMethod('playFullscreen', {
                          'url': details.getVideoUrl(appData),
                          'seconds': seconds,
                        });
                        // playFullscreen
                      },
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.blue,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        var screen = HiveCommentDialog(
                          author: widget.vm.author,
                          permlink: widget.vm.permlink,
                          username: appData.username ?? "",
                          hasKey: appData.keychainData?.hasId ?? "",
                          hasAuthKey: appData.keychainData?.hasAuthKey ?? "",
                          onClose: () {},
                          onDone: () {
                            setState(() {
                              _fetchHiveInfoForThisVideo =
                                  fetchHiveInfoForThisVideo(appData.rpc);
                            });
                          },
                        );
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (c) => screen));
                      },
                      icon: Icon(
                        Icons.message_outlined,
                        color: Colors.blue,
                      ),
                    ),
                    if (data.activeVotes
                            .where(
                                (element) => element.voter == appData.username)
                            .length ==
                        0)
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              clipBehavior: Clip.hardEdge,
                              builder: (context) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: HiveUpvoteDialog(
                                    author: widget.vm.author,
                                    permlink: widget.vm.permlink,
                                    username: appData.username ?? "",
                                    hasKey: appData.keychainData?.hasId ?? "",
                                    hasAuthKey:
                                        appData.keychainData?.hasAuthKey ?? "",
                                    activeVotes: data.activeVotes,
                                    onClose: () {},
                                    onDone: () {
                                      setState(() {
                                        _fetchHiveInfoForThisVideo =
                                            fetchHiveInfoForThisVideo(
                                                appData.rpc);
                                      });
                                    },
                                  ),
                                );
                              });
                        },
                        icon: Icon(
                          Icons.thumbs_up_down,
                          color: Colors.blue,
                        ),
                      )
                    else
                      Container(),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Text('Loading hive payout info');
        }
      },
    );
  }

// video description
  void showModalForDescription(VideoDetails details) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height - 230.0,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 55),
                child: descriptionMarkDown(details.description),
              ),
              Container(
                height: 55,
                child: AppBar(
                  title: Text(details.title),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.fullscreen),
                    ),
                    details.playUrl.contains('ipfs')
                        ? IconButton(
                            onPressed: () {
                              var ipfsHash = details.playUrl
                                  .replaceAll(
                                      "https://ipfs-3speak.b-cdn.net/ipfs/", "")
                                  .replaceAll("/manifest.m3u8", "");
                              Share.share(
                                  "Copy this IPFS Hash & Pin it on your system - $ipfsHash");
                            },
                            icon: Image.asset(
                              'assets/ipfs-logo.png',
                              width: 20,
                              height: 20,
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

//endregion

//region Video Comments
// video comments
  Widget listTile(HiveComment comment) {
    var item = comment;
    var userThumb = server.userOwnerThumb(item.author);
    var body = item.body;
    double width = MediaQuery.of(context).size.width - 90 - 20;
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCircleAvatar(height: 25, width: 25, url: userThumb),
          Container(margin: const EdgeInsets.only(right: 10)),
          SizedBox(
            width: width,
            child: MarkdownBody(
              data: Utilities.removeAllHtmlTags(body)
                  .split('')
                  .take(100)
                  .join(''),
              shrinkWrap: true,
              onTapLink: (text, url, title) {
                launchUrl(Uri.parse(url ?? 'https://google.com'));
              },
            ),
          ),
          const Icon(Icons.arrow_right_outlined)
        ],
      ),
    );
  }

// video comments
  Widget commentsSection(List<HiveComment> comments, HiveUserData appData) {
    var filtered = comments.where((element) =>
        (element.netRshares ?? 0) >= 0 && (element.authorReputation ?? 0) >= 0);
    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: const Text('No comments added'),
      );
    }
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comments :', style: Theme.of(context).textTheme.bodyLarge),
            listTile(filtered.last)
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return VideoDetailsComments(
                author: widget.vm.author,
                permlink: widget.vm.permlink,
                rpc: appData.rpc,
              );
            },
          ),
        );
      },
    );
  }

// video comments
  Widget videoComments(HiveUserData appData) {
    return FutureBuilder(
      future: _loadComments,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong while loading video comments - ${snapshot.error?.toString() ?? ""}';
          return Container(margin: const EdgeInsets.all(10), child: Text(text));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data! as List<HiveComment>;
          return commentsSection(data, appData);
        } else {
          return Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              children: const [
                SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(),
                ),
                SizedBox(width: 10),
                Text('Loading comments')
              ],
            ),
          );
        }
      },
    );
  }

//endregion

  Widget videoWithDetailsWithoutRecommendation(
    VideoDetails details,
    HiveUserData appData,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 230),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return titleAndSubtitle(details, appData);
          } else if (index == 1) {
            return videoComments(appData);
          } else {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              title: const Text('Unknown'),
            );
          }
        },
        separatorBuilder: (context, index) =>
            const Divider(thickness: 0, height: 15, color: Colors.transparent),
        itemCount: 2,
      ),
    );
  }

// container list view
  Widget videoWithDetails(VideoDetails details, HiveUserData appData) {
    return FutureBuilder(
        future: recommendedVideos,
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            return videoWithDetailsWithoutRecommendation(details, appData);
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            var recommendations =
                snapshot.data as List<VideoRecommendationItem>;
            return Container(
              margin: const EdgeInsets.only(top: 230),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return titleAndSubtitle(details, appData);
                  } else if (index == 1) {
                    return videoComments(appData);
                  } else if (index == 2) {
                    return const ListTile(
                      title: Text('Recommended Videos'),
                    );
                  } else {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      minVerticalPadding: 0,
                      title: videoRecommendationListItem(
                        recommendations[index - 3],
                      ),
                      onTap: () {
                        var viewModel = VideoDetailsViewModel(
                          author: recommendations[index - 3].owner,
                          permlink: recommendations[index - 3].mediaid,
                        );
                        var screen = VideoDetailsScreen(vm: viewModel);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (c) => screen),
                        );
                      },
                    );
                  }
                },
                separatorBuilder: (context, index) => const Divider(
                    thickness: 0, height: 15, color: Colors.transparent),
                itemCount: recommendations.length + 2,
              ),
            );
          } else {
            return videoWithDetailsWithoutRecommendation(details, appData);
          }
        });
  }

// container list view - recommendations

  late BetterPlayerController _betterPlayerController;

  Widget videoRecommendationListItem(VideoRecommendationItem item) {
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.image,
      userThumbUrl: server.userOwnerThumb(item.owner),
      title: item.title,
      subtitle: "",
      onUserTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => UserChannelScreen(owner: item.owner)));
      },
      user: item.owner,
      permlink: item.mediaid,
      shouldResize: false,
      isIpfs: false,
    );
  }

  void setupVideo(String url) {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      autoPlay: true,
      fullScreenByDefault: false,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enablePip: true,
        enableFullscreen: false,
        enableSkips: true,
        pipMenuIcon: Icons.picture_in_picture,
      ),
      autoDetectFullscreenAspectRatio: false,
      autoDetectFullscreenDeviceOrientation: false,
      autoDispose: true,
      expandToFill: true,
    );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url.replaceAll("/manifest.m3u8", "/480p/index.m3u8"),
      videoFormat: BetterPlayerVideoFormat.hls,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

// main container
  @override
  Widget build(BuildContext context) {
    var userData = Provider.of<HiveUserData>(context);
    if (_loadComments == null) {
      setState(() {
        _loadComments = widget.vm.loadFirstSetOfComments(
          widget.vm.author,
          widget.vm.permlink,
          userData.rpc,
        );
      });
    }
    if (_fetchHiveInfoForThisVideo == null) {
      setState(() {
        _fetchHiveInfoForThisVideo = fetchHiveInfoForThisVideo(userData.rpc);
      });
    }
    return FutureBuilder(
      future: widget.vm.getVideoDetails(),
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong while loading video information - ${snapshot.error?.toString() ?? ""}';
          return container(widget.vm.author, Text(text));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data as VideoDetails?;
          if (data != null) {
            var url = data.getVideoUrl(userData);
            setupVideo(url);
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    videoWithDetails(data, userData),
                    SizedBox(
                      height: 230,
                      child: BetterPlayer(
                        controller: _betterPlayerController,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return container(
              widget.vm.author,
              const Text(
                  "Something went wrong while loading video information"),
            );
          }
        } else {
          return container(
            widget.vm.author,
            const LoadingScreen(
              title: 'Loading Data',
              subtitle: 'Please wait',
            ),
          );
        }
      },
    );
  }
}
