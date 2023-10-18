import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_comments/new_hive_comment/new_hive_comment.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class HiveCommentWidget extends StatefulWidget {
  const HiveCommentWidget({Key? key, required this.comment}) : super(key: key);
  final NewHiveComment comment;

  @override
  State<HiveCommentWidget> createState() => _HiveCommentWidgetState();
}

class _HiveCommentWidgetState extends State<HiveCommentWidget> {
  var isHidden = false;
  var expanded = false;

  @override
  void initState() {
    super.initState();
  //   isHidden = (widget.comment.authorReputation ?? 0) < 0 ||
  //       (widget.comment.netRshares ?? 0) < 0;
  }

  Widget _comment(String text) {
    if (isHidden) {
      if (expanded) {
        return Text(text);
      } else {
        return Text(
          '--- HIDDEN ---',
          style: TextStyle(color: Colors.grey),
        );
      }
    }
    return MarkdownBody(
      data: Utilities.removeAllHtmlTags(text),
      shrinkWrap: true,
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  Widget _listTile() {
    var item = widget.comment;
    var userThumb = server.userOwnerThumb(item.author.username);
    var author = item.author.username;
    var body = item.body;
    var votes = item.stats!.numVotes!;
    var timeInString =
        item.createdAt != null ? "📆 ${timeago.format(item.createdAt!)}" : "";
    var text =
        "👤  $author  👍  $votes     $timeInString";
    var depth = (item.children!.isNotEmpty ? 50.0 : 0.2 * 25.0);
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
                _comment(body ?? ""),
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
        if (isHidden) {
          setState(() {
            expanded = !expanded;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _listTile();
  }
}
