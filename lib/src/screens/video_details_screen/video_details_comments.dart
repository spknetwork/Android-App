import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class VideoDetailsComments extends StatefulWidget {
  const VideoDetailsComments(
      {Key? key, required this.author, required this.permlink})
      : super(key: key);
  final String author;
  final String permlink;

  @override
  State<VideoDetailsComments> createState() => _VideoDetailsCommentsState();
}

class _VideoDetailsCommentsState extends State<VideoDetailsComments> {
  late Future<List<HiveComment>> _loadComments;

  Future<List<HiveComment>> loadComments(String author, String permlink) async {
    var client = http.Client();
    var body =
        hiveCommentRequestToJson(HiveCommentRequest.from([author, permlink]));
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      var hiveCommentsResponse = hiveCommentsFromString(response.body);
      var comments = hiveCommentsResponse.result;
      for (var i = 0; i < comments.length; i++) {
        if (comments[i].children > 0) {
          if (comments
              .where((e) => e.parentPermlink == comments[i].permlink)
              .isEmpty) {
            var newComments =
                await loadComments(comments[i].author, comments[i].permlink);
            comments.insertAll(i + 1, newComments);
          }
        }
      }
      return comments;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadComments = loadComments(widget.author, widget.permlink);
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
    var depth = (item.depth * 25.0) - 25;
    double width = MediaQuery.of(context).size.width - 70 - depth;
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: EdgeInsets.only(left: depth)),
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
          )
        ],
      ),
      onTap: () {
        print("Tapped");
      },
    );
  }

  Widget commentsListView(List<HiveComment> data) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.separated(
          itemBuilder: (context, index) {
            return listTile(data[index]);
          },
          separatorBuilder: (context, index) => const Divider(
                height: 10,
                color: Colors.blueGrey,
              ),
          itemCount: data.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: FutureBuilder(
        future: _loadComments,
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            String text =
                'Something went wrong while loading video comments - ${snapshot.error?.toString() ?? ""}';
            return Container(
                margin: const EdgeInsets.all(10), child: Text(text));
          } else if (snapshot.hasData) {
            var data = snapshot.data! as List<HiveComment>;
            return commentsListView(data);
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Spacer(),
                  SizedBox(child: CircularProgressIndicator(value: null)),
                  SizedBox(height: 10),
                  Text('Loading comments'),
                  Spacer(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
