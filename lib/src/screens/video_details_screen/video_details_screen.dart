import 'dart:developer';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  void onUserTap() {
    Navigator.of(context).pushNamed("/userChannel/${widget.vm.author}");
  }

  Widget container(String title, Widget body) {
    return Scaffold(
      body: body,
    );
  }

  Widget descriptionMarkDown(String markDown) {
    return Markdown(
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launch(url!);
      },
    );
  }

  Widget titleAndSubtitle(VideoDetails details) {
    String string =
        "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
    return InkWell(
      child: Container(
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
            const Icon(Icons.keyboard_arrow_down_outlined),
          ],
        ),
      ),
      onTap: () {
        log('Hello');
      },
    );
  }

  Widget listTile(HiveComment comment) {
    var item = comment;
    var userThumb = server.userOwnerThumb(item.author);
    var author = item.author;
    var body = item.body;
    var upVotes = item.activeVotes.where((e) => e.percent > 0).length;
    var downVotes = item.activeVotes.where((e) => e.percent < 0).length;
    var payout = item.pendingPayoutValue.replaceAll(" HBD", "");
    var timeInString =
    item.createdAt != null ? "📆 ${timeago.format(item.createdAt!)}" : "";
    var text =
        "👤  $author  👍  $upVotes  👎  $downVotes  💰  $payout  $timeInString";
    // var depth = (item.depth * 25.0) - 25;
    double width = MediaQuery.of(context).size.width - 90;
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCircleAvatar(height: 25, width: 25, url: userThumb),
          Container(margin: const EdgeInsets.only(right: 10)),
          SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownBody(
                  data: Utilities.removeAllHtmlTags(body),
                  shrinkWrap: true,
                  onTapLink: (text, url, title) {
                    launch(url!);
                  },
                ),
                Container(margin: const EdgeInsets.only(bottom: 10)),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          const Icon(Icons.expand)
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
      child: listTile(comments.last),
      onTap: () {

      },
    );
  }

  Widget videoWithDetails(VideoDetails details) {
    return ListView(
      children: [
        SizedBox(
          height: 230,
          child: SPKVideoPlayer(
            playUrl: details.playUrl,
          ),
        ),
        titleAndSubtitle(details),
        videoComments(),
      ],
    );
  }

  Widget videoComments() {
    return FutureBuilder(
        future: widget.vm.loadComments(widget.vm.author, widget.vm.permlink),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            String text =
                'Something went wrong - ${snapshot.error?.toString() ?? ""}';
            return Container(margin: const EdgeInsets.all(10), child: Text(text));
          } else if (snapshot.hasData) {
            var data = snapshot.data! as List<HiveComment>;
            return commentsSection(data);
          } else {
            return Container(margin: const EdgeInsets.all(10), child: const Text('Loading comments'));
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
}
