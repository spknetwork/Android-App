import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/video_details_screen/video_details_comments.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';

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
  static const List<Tab> tabs = [
    Tab(text: 'Video'),
    Tab(text: 'Description'),
    Tab(text: 'Comments')
  ];

  Future<VideoDetails> getVideoDetails() async {
    final endPoint =
        "${server.domain}/apiv2/@${widget.vm.author}/${widget.vm.permlink}";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      VideoDetails data = videoDetailsFromJson(response.body);
      return data;
    } else {
      throw "Status code = ${response.statusCode}";
    }
  }

  Widget container(String title, Widget body) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: body,
    );
  }

  Widget descriptionMarkDown(String markDown) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Markdown(
        data: markDown,
      ),
    );
  }

  Widget tabBar(VideoDetails details) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(details.title),
              bottom: const TabBar(tabs: tabs),
            ),
            body: TabBarView(
              children: [
                SPKVideoPlayer(
                  playUrl: details.playUrl,
                ),
                descriptionMarkDown(details.description),
                VideoDetailsCommentsWidget(
                    author: details.owner, permlink: details.permlink),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getVideoDetails(),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            String text =
                'Something went wrong - ${snapshot.error?.toString() ?? ""}';
            return container(widget.vm.author, Text(text));
          } else if (snapshot.hasData) {
            var data = snapshot.data! as VideoDetails;
            return tabBar(data);
          } else {
            return container(widget.vm.author, const LoadingScreen());
          }
        });
  }
}
