import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/request/hive_comment_request.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class VideoDetailsCommentsWidget extends StatefulWidget {
  const VideoDetailsCommentsWidget(
      {Key? key, required this.author, required this.permlink})
      : super(key: key);
  final String author;
  final String permlink;

  @override
  _VideoDetailsCommentsWidgetState createState() =>
      _VideoDetailsCommentsWidgetState();
}

class _VideoDetailsCommentsWidgetState extends State<VideoDetailsCommentsWidget>
    with AutomaticKeepAliveClientMixin<VideoDetailsCommentsWidget> {
  @override
  bool get wantKeepAlive => true;

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
                  data: body,
                  shrinkWrap: true,
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

  Widget commentsListView(List<HiveComment> comments) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return listTile(comments[index]);
        },
        separatorBuilder: (context, index) => const Divider(
              height: 10,
              color: Colors.blueGrey,
            ),
        itemCount: comments.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadComments(widget.author, widget.permlink),
        builder: (builder, snapshot) {
          if (snapshot.hasError) {
            String text =
                'Something went wrong - ${snapshot.error?.toString() ?? ""}';
            return Text(text);
          } else if (snapshot.hasData) {
            var data = snapshot.data! as List<HiveComment>;
            return commentsListView(data);
          } else {
            return const LoadingScreen();
          }
        });
  }
}
