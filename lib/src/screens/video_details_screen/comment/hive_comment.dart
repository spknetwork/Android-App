import 'package:acela/src/models/hive_comments/new_hive_comment/newest_comment_model.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/comment/comment_action_menu.dart';
import 'package:acela/src/screens/video_details_screen/comment/controller/comment_controller.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/user_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class HiveCommentWidget extends StatefulWidget {
  const HiveCommentWidget(
      {Key? key, required this.comment, required this.index})
      : super(key: key);
  final CommentItemModel comment;
  final int index;

  @override
  State<HiveCommentWidget> createState() => _HiveCommentWidgetState();
}

class _HiveCommentWidgetState extends State<HiveCommentWidget> {
  @override
  Widget build(BuildContext context) {
    return CommentTile(
      comment: widget.comment,
      isPadded: widget.comment.depth != 1,
      index: widget.index,
    );
  }
}

class CommentTile extends StatefulWidget {
  const CommentTile({Key? key, required this.comment, required this.isPadded, required this.index})
      : super(key: key);

  final CommentItemModel comment;
  final bool isPadded;
  final int index;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile>
    with AutomaticKeepAliveClientMixin {
  late int votes;

  @override
  void initState() {
    votes = widget.comment.stats?.totalVotes ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var item = widget.comment;
    var author = item.author;
    var body = item.body;
    var timeInString = "${timeago.format(item.created)}";
    var depth = (widget.isPadded ? 50.0 : 0.2 * 25.0);
    var style = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    return InkWell(
      onTap: () {
        _showBottomSheet(item, () {
          setState(() {
            votes++;
          });
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.only(
            left: depth + 15,
            right: 15,
            bottom: 15,
            top: widget.isPadded ? 0 : 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserProfileImage(userName: item.author),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Text(author, style: style),
                      const SizedBox(
                        width: 12,
                      ),
                      Icon(
                        Icons.thumb_up,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(votes.toString(), style: style),
                      const SizedBox(
                        width: 12,
                      ),
                      Icon(
                        Icons.schedule,
                        size: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                          child: Text(
                        timeInString,
                        style: style,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            _comment(body),
          ],
        ),
      ),
    );
  }

  Widget _comment(String text) {
    return MarkdownBody(
      data: Utilities.removeAllHtmlTags(text),
      shrinkWrap: true,
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  void _showBottomSheet(CommentItemModel item, VoidCallback onUpvote) {
    final controller = context.read<CommentController>();
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1B1A1A),
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      context: context,
      builder: (context) => CommentActionMenu(
        depth: item.depth,
        onSubCommentAdded: (newComment) {
          controller.addSubLevelComment(newComment, widget.index);
        },
        onUpVote: onUpvote,
        appData: context.read<HiveUserData>(),
        author: item.author,
        permlink: item.permlink,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
