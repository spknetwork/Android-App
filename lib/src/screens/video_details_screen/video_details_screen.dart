import 'dart:async';
import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_recommendation_models/video_recommendation.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_info.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({Key? key, required this.vm}) : super(key: key);
  final VideoDetailsViewModel vm;

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  late Future<List<VideoRecommendationItem>> recommendedVideos;
  List<VideoRecommendationItem> recommendations = [];
  late Future<List<HiveComment>> _loadComments;
  Map<String, PayoutInfo?> payoutData = {};
  double? payout;
  int? upVotes;
  int? downVotes;

  @override
  void initState() {
    super.initState();
    // widget.vm.getRecommendedVideos().then((value) {
    //   setState(() {
    //     recommendations = value;
    //   });
    //   var i = 0;
    //   Timer.periodic(const Duration(seconds: 1), (timer) {
    //     fetchHiveInfo(value[i].owner, value[i].mediaid);
    //     i += 1;
    //     if (i == value.length) {
    //       timer.cancel();
    //     }
    //   });
    // });
    // _loadComments =
    //     widget.vm.loadFirstSetOfComments(widget.vm.author, widget.vm.permlink);
    // fetchHiveInfoForThisVideo();
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
  void fetchHiveInfoForThisVideo() async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
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
      setState(() {
        payout = result.payout;
        upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
        downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  // fetch hive info
  void fetchHiveInfo(String user, String permlink) async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {"author": user, "permlink": permlink, "observer": ""}
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == permlink)
          .first;
      setState(() {
        var upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
        var downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
        payoutData["$user/$permlink"] = PayoutInfo(
          payout: result.payout,
          downVotes: downVotes,
          upVotes: upVotes,
        );
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  // video description
  Widget titleAndSubtitle(VideoDetails details) {
    String string =
        "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
    String priceAndVotes =
        (payout != null && upVotes != null && downVotes != null)
            ? "\$ ${payout!.toStringAsFixed(3)} · 👍 $upVotes · 👎 $downVotes"
            : "";
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
          InkWell(
            child: Row(
              children: [
                CustomCircleAvatar(
                  height: 40,
                  width: 40,
                  url: server.userOwnerThumb(details.owner),
                ),
                SizedBox(width: 10),
                Text(details.owner,
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (c) => UserChannelScreen(owner: details.owner)));
            },
          )
        ],
      ),
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
                      onPressed: () {
                        var route = MaterialPageRoute(builder: (context) {
                          return VideoDetailsInfoWidget(details: details);
                        });
                        Navigator.of(context).push(route);
                      },
                      icon: const Icon(Icons.fullscreen),
                    )
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
  Widget commentsSection(List<HiveComment> comments) {
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
                  author: widget.vm.author, permlink: widget.vm.permlink);
            },
          ),
        );
      },
    );
  }

  // video comments
  Widget videoComments() {
    return FutureBuilder(
      future: _loadComments,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong while loading video comments - ${snapshot.error?.toString() ?? ""}';
          return Container(margin: const EdgeInsets.all(10), child: Text(text));
        } else if (snapshot.hasData) {
          var data = snapshot.data! as List<HiveComment>;
          return commentsSection(data);
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

  // container list view
  Widget videoWithDetails(VideoDetails details) {
    return Container(
      margin: const EdgeInsets.only(top: 230),
      child: ListView.separated(
        itemBuilder: (context, index) {
          if (index == 0) {
            return titleAndSubtitle(details);
          } else if (index == 1) {
            return videoComments();
          } else if (index == 2) {
            return const ListTile(
              title: Text('Recommended Videos'),
            );
          } else {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              title: videoRecommendationListItem(recommendations[index - 3]),
            );
          }
        },
        separatorBuilder: (context, index) =>
            const Divider(thickness: 0, height: 15, color: Colors.transparent),
        itemCount: recommendations.length + 2,
      ),
    );
  }

  // container list view - recommendations
  Widget videoRecommendationListItem(VideoRecommendationItem item) {
    double? payoutAmount = payoutData["${item.owner}/${item.mediaid}"]?.payout;
    int? upVotes = payoutData["${item.owner}/${item.mediaid}"]?.upVotes;
    int? downVotes = payoutData["${item.owner}/${item.mediaid}"]?.downVotes;
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
      downVotes: downVotes,
      upVotes: upVotes,
      payout: payoutAmount,
    );
  }

  // main container
  @override
  Widget build(BuildContext context) {
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
            return Scaffold(
              body: SafeArea(
                child: Stack(
                  children: [
                    videoWithDetails(data),
                    SizedBox(
                      height: 230,
                      child: SPKVideoPlayer(
                        playUrl: data.playUrl,
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
          return container(widget.vm.author, const LoadingScreen());
        }
      },
    );
  }
}
