import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  @override
  void initState() {
    super.initState();
    widget.vm.getRecommendedVideos().then((value) {
      setState(() {
        recommendations = value;
      });
    });
    _loadComments =
        widget.vm.loadFirstSetOfComments(widget.vm.author, widget.vm.permlink);
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
        launch(url!);
      },
    );
  }

  // video description
  Widget titleAndSubtitleCommon(VideoDetails details, bool fullScreen) {
    String string =
        "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
    var fullScreenButton = IconButton(
      onPressed: () {
        var route = MaterialPageRoute(builder: (context) {
          return VideoDetailsInfoWidget(details: details);
        });
        Navigator.of(context).push(route);
      },
      icon: const Icon(Icons.fullscreen),
    );
    var closeButton = IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: const Icon(Icons.close),
    );
    var downIcon = const Icon(Icons.arrow_drop_down_outlined);
    List<Widget> children = [
      Expanded(
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details.title, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 3),
            Text(string, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ];
    if (fullScreen) {
      children.add(fullScreenButton);
      children.add(closeButton);
    } else {
      children.add(downIcon);
    }
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
                margin: const EdgeInsets.only(top: 70),
                child: descriptionMarkDown(details.description),
              ),
              titleAndSubtitleCommon(details, true),
            ],
          ),
        );
      },
    );
  }

  // video description
  Widget titleAndSubtitle(VideoDetails details) {
    return InkWell(
      child: titleAndSubtitleCommon(details, false),
      onTap: () {
        showModalForDescription(details);
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
                launch(url!);
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
    if (comments.isEmpty) {
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
            listTile(comments.last)
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return VideoDetailsComments(
              author: widget.vm.author, permlink: widget.vm.permlink);
        }));
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
                      child: CircularProgressIndicator(value: null)),
                  SizedBox(width: 10),
                  Text('Loading comments')
                ],
              ));
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
        separatorBuilder: (context, index) => const Divider(thickness: 0, height: 15, color: Colors.transparent),
        itemCount: recommendations.length + 2,
      ),
    );
  }

  // container list view - recommendations
  Widget videoRecommendationListItem(VideoRecommendationItem item) {
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.image,
      userThumbUrl: server.userOwnerThumb(item.owner),
      title: item.title,
      subtitle: "👤 ${item.owner}",
      onUserTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (c) => UserChannelScreen(owner: item.owner)));
      },
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
        } else if (snapshot.hasData) {
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
              )),
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
