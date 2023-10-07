import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/cached_image.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NewFeedListItem extends StatefulWidget {
  const NewFeedListItem({
    Key? key,
    required this.createdAt,
    required this.duration,
    required this.views,
    required this.thumbUrl,
    required this.author,
    required this.title,
    required this.permlink,
    required this.onTap,
    required this.onUserTap,
    required this.comments,
    required this.votes,
    required this.hiveRewards,
    this.item,
    this.appData,
  }) : super(key: key);

  final DateTime? createdAt;
  final double? duration;
  final int? views;
  final String thumbUrl;
  final String author;
  final String title;
  final String permlink;
  final int? votes;
  final int? comments;
  final double? hiveRewards;
  final Function onTap;
  final Function onUserTap;
  final GQLFeedItem? item;
  final HiveUserData? appData;

  @override
  State<NewFeedListItem> createState() => _NewFeedListItemState();
}

class _NewFeedListItemState extends State<NewFeedListItem> {
  Widget listTile() {
    String timeInString = widget.createdAt != null
        ? "📝 ${timeago.format(widget.createdAt!)}"
        : "";
    String durationString = widget.duration != null
        ? " 🕚 ${Utilities.formatTime(widget.duration!.toInt())} "
        : "";
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          title: CachedImage(
            imageUrl: widget.thumbUrl,
            imageHeight: 230,
          ),
          subtitle: ListTile(
            contentPadding: EdgeInsets.all(2),
            dense: true,
            leading: InkWell(
              child: ClipOval(
                child: CachedImage(
                  imageHeight: 40,
                  imageWidth: 40,
                  loadingIndicatorSize: 25,
                  imageUrl: server.userOwnerThumb(widget.author),
                ),
              ),
              onTap: () {
                widget.onUserTap();
                var screen = UserChannelScreen(owner: widget.author);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(widget.title),
            ),
            subtitle: Row(
              children: [
                InkWell(
                  child: Text('👤 ${widget.author}'),
                  onTap: () {
                    widget.onUserTap();
                    var screen = UserChannelScreen(owner: widget.author);
                    var route = MaterialPageRoute(builder: (c) => screen);
                    Navigator.of(context).push(route);
                  },
                ),
                SizedBox(width: 10),
                payoutInfo(),
              ],
            ),
          ),
          onTap: () {
            widget.onTap();
            if (widget.item == null || widget.appData == null) {
              var viewModel = VideoDetailsViewModel(
                author: widget.author,
                permlink: widget.permlink,
              );
              var screen = VideoDetailsScreen(vm: viewModel);
              var route = MaterialPageRoute(builder: (context) => screen);
              Navigator.of(context).push(route);
            } else {
              var screen = NewVideoDetailsScreen(
                  item: widget.item!, appData: widget.appData!);
              var route = MaterialPageRoute(builder: (context) => screen);
              Navigator.of(context).push(route);
            }
          },
        ),
        Column(
          children: [
            const SizedBox(height: 208),
            Row(
              children: [
                SizedBox(width: 5),
                if (timeInString.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(timeInString,
                        style: TextStyle(color: Colors.white)),
                  ),
                Spacer(),
                if (durationString.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(durationString,
                        style: TextStyle(color: Colors.white)),
                  ),
                SizedBox(width: 5),
              ],
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return listTile();
  }

  Widget payoutInfo() {
    String priceAndVotes = "👍 ${widget.votes ?? 0} · 💬 ${widget.comments}";
    return Text(priceAndVotes);
  }
}
