import 'dart:developer';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/models/video_recommendation_models/video_recommendation.dart';
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
import 'package:bottom_sheet/bottom_sheet.dart';

class VideoDetailsScreen extends StatefulWidget {
  const VideoDetailsScreen({Key? key, required this.vm}) : super(key: key);
  final VideoDetailsViewModel vm;

  static String routeName(String owner, String permLink) {
    return '/watch?owner=$owner&permlink=$permLink';
  }

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  GlobalKey<State<SPKVideoPlayer>> key = GlobalKey<State<SPKVideoPlayer>>();

  void onUserTap() {
    Navigator.of(context).pushNamed("/userChannel/${widget.vm.author}");
  }

  Widget container(String title, Widget body) {
    return Scaffold(
      body: body,
    );
  }

  Widget descriptionMarkDown(String markDown) {
    var color = Theme.of(context).brightness == Brightness.dark
        ? Colors.black87
        : Colors.white;
    return Container(
      margin: const EdgeInsets.all(10),
      child: MarkdownBody(
        data: Utilities.removeAllHtmlTags(markDown),
        onTapLink: (text, url, title) {
          launch(url!);
        },
      ),
    );
  }

  Widget titleAndSubtitleCommon(VideoDetails details) {
    String string =
        "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
    return Container(
      margin: const EdgeInsets.all(10),
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
                Text(string, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_down_outlined),
        ],
      ),
    );
  }

  void showModal(VideoDetails details) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height-200.0,
          child: ListView(
            children: [
              titleAndSubtitleCommon(details),
              descriptionMarkDown(details.description),
            ],
          ),
        );
      },
    );
  }

  Widget titleAndSubtitle(VideoDetails details) {
    return InkWell(
      child: titleAndSubtitleCommon(details),
      onTap: () {
        showModal(details);
      },
    );
  }

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
              data: Utilities.removeAllHtmlTags(body),
              shrinkWrap: true,
              onTapLink: (text, url, title) {
                launch(url!);
              },
            ),
          ),
          const Icon(Icons.arrow_drop_down_outlined)
        ],
      ),
    );
  }

  Widget commentsSection(List<HiveComment> comments) {
    if (comments.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(10),
        child: const Text('No comments added'),
      );
    }
    return InkWell(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comments ${comments.length}',
                style: Theme.of(context).textTheme.bodyLarge),
            listTile(comments.last)
          ],
        ),
      ),
      onTap: () {},
    );
  }

  Widget videoWithDetails(VideoDetails details) {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return SizedBox(
            height: 230,
            child: SPKVideoPlayer(
              key: key,
              playUrl: details.playUrl,
            ),
          );
        } else if (index == 1) {
          return titleAndSubtitle(details);
        } else if (index == 2) {
          return videoComments();
        } else {
          return ListTile(
            title: videoRecommendationListItem(recommendations[index - 3]),
          );
        }
      },
      separatorBuilder: (context, index) => Container(),
      itemCount: recommendations.length + 3,
    );
  }

  Widget videoComments() {
    return FutureBuilder(
        future: widget.vm.loadComments(widget.vm.author, widget.vm.permlink),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            String text =
                'Something went wrong - ${snapshot.error?.toString() ?? ""}';
            return Container(
                margin: const EdgeInsets.all(10), child: Text(text));
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.vm.getVideoDetails(),
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          String text =
              'Something went wrong - ${snapshot.error?.toString() ?? ""}';
          return container(widget.vm.author, Text(text));
        } else if (snapshot.hasData) {
          var data = snapshot.data as VideoDetails?;
          if (data != null) {
            return Scaffold(
              body: SafeArea(
                child: videoWithDetails(data),
              ),
            );
          } else {
            return container(
              widget.vm.author,
              const Text("Something went wrong"),
            );
          }
        } else {
          return container(widget.vm.author, const LoadingScreen());
        }
      },
    );
  }

  late Future<List<VideoRecommendationItem>> recommendedVideos;
  List<VideoRecommendationItem> recommendations = [];

  @override
  void initState() {
    super.initState();
    widget.vm.getRecommendedVideos().then((value) {
      setState(() {
        recommendations = value;
      });
    });
  }

  Widget videoRecommendationListItem(VideoRecommendationItem item) {
    return ListTile(
      title: ListTileVideo(
        placeholder: 'assets/branding/three_speak_logo.png',
        url: item.image,
        userThumbUrl: server.userOwnerThumb(item.owner),
        title: item.title,
        subtitle: "",
        onUserTap: () {
          key.currentState?.widget.pauseVideo();
          // TO-DO - pause video before going to next screen
          // Navigator.of(context).pushNamed("/userChannel/${item.owner}");
        },
      ),
      onTap: () {
        // TO-DO - pause video before going to next screen
        // Navigator.of(context)
        //     .pushNamed(VideoDetailsScreen.routeName(item.owner, item.mediaid));
      },
    );
  }
}
