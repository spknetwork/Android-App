import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class GQLFeedListItemWidget extends StatefulWidget {
  const GQLFeedListItemWidget({
    Key? key,
    required this.gqlFeedItem,
  }) : super(key: key);
  final GQLFeedItem gqlFeedItem;

  @override
  State<GQLFeedListItemWidget> createState() => _GQLFeedListItemWidgetState();
}

class _GQLFeedListItemWidgetState extends State<GQLFeedListItemWidget> {
  Widget listTile() {
    String timeInString = widget.gqlFeedItem.createdAt != null
        ? "📝 ${timeago.format(widget.gqlFeedItem.createdAt!)}"
        : "";
    String durationString = widget.gqlFeedItem.spkvideo?.duration != null
        ? " 🕚 ${Utilities.formatTime(widget.gqlFeedItem.spkvideo!.duration!.toInt())} "
        : "";
    String viewsString =
    widget.gqlFeedItem.stats?.numComments != null ? "💬 ${widget.gqlFeedItem.stats!.numComments} comments" : "";
    String author = widget.gqlFeedItem.author?.username ?? 'sagarkothari88';
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          title: Image.network(
            widget.gqlFeedItem.spkvideo?.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            height: 230,
          ),
          subtitle: ListTile(
            contentPadding: EdgeInsets.all(2),
            dense: true,
            leading: InkWell(
              child: CustomCircleAvatar(
                width: 40,
                height: 40,
                url: server.userOwnerThumb(author),
              ),
              onTap: () {
                var screen = UserChannelScreen(owner: author);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(widget.gqlFeedItem.title ?? ''),
            ),
            subtitle: Row(
              children: [
                InkWell(
                  child: Text('👤 $author'),
                  onTap: () {
                    var screen = UserChannelScreen(owner: author);
                    var route = MaterialPageRoute(builder: (c) => screen);
                    Navigator.of(context).push(route);
                  },
                ),
                SizedBox(width: 10),
                Text("\$ ${(widget.gqlFeedItem.stats?.totalHiveReward ?? 0.0).toStringAsFixed(3)} · 👍 ${widget.gqlFeedItem.stats?.numVotes ?? 0.0} · 🏷️ ${widget.gqlFeedItem.tags?.first ?? 'No Tag/Community'}"),
              ],
            ),
          ),
          onTap: () {
            var viewModel = VideoDetailsViewModel(
              author: author,
              permlink: widget.gqlFeedItem.permlink ?? '',
            );
            var screen = VideoDetailsScreen(vm: viewModel);
            var route = MaterialPageRoute(builder: (context) => screen);
            Navigator.of(context).push(route);
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
                if (viewsString.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(viewsString,
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
}
