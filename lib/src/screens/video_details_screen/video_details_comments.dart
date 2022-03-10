import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/response/hive_comments.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class VideoDetailsComments extends StatelessWidget {
  const VideoDetailsComments({Key? key, required this.data}) : super(key: key);
  final List<HiveComment> data;

  Widget listTile(HiveComment comment, BuildContext context) {
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

  Widget commentsListView(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView.separated(
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Text('Comments', style: Theme.of(context).textTheme.bodyLarge),
              );
            } else {
              return listTile(data[index - 1], context);
            }
          },
          separatorBuilder: (context, index) => const Divider(
            height: 10,
            color: Colors.blueGrey,
          ),
          itemCount: data.length + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return commentsListView(context);
  }
}