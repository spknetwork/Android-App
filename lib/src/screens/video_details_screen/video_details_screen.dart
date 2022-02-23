import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_recommendation.dart';
import 'package:acela/src/screens/video_details_screen/video_details_tabbed_widget.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

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
  var fullscreen = false;

  void onUserTap() {
    Navigator.of(context).pushNamed("/userChannel/${widget.vm.author}");
  }

  Widget container(String title, Widget body) {
    return Scaffold(
      appBar: fullscreen
          ? null
          : AppBar(
              title: Text(title),
              actions: [
                IconButton(
                  onPressed: onUserTap,
                  icon: const Icon(Icons.person),
                ),
              ],
            ),
      body: body,
    );
  }

  Widget descriptionMarkDown(String markDown) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Markdown(
        data: Utilities.removeAllHtmlTags(markDown),
        onTapLink: (text, url, title) {
          launch(url!);
        },
      ),
      // Html(data: markdownToHtml(markDown)),
    );
  }

  List<Widget> tabBarChildren(VideoDetails details) {
    return [
      SPKVideoPlayer(
        playUrl: details.playUrl,
        handleFullScreen: (value) {
          setState(() {
            fullscreen = value;
          });
        },
      ),
      descriptionMarkDown(details.description),
      VideoDetailsCommentsWidget(vm: widget.vm),
      VideoDetailsRecommendationWidget(vm: widget.vm),
    ];
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
            return VideoDetailsTabbedWidget(
              children: tabBarChildren(data),
              title: data.title,
              onUserTap: onUserTap,
              fullscreen: fullscreen,
              routeName:
                  "${server.domain}${VideoDetailsScreen.routeName(data.owner, data.permlink)}",
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
