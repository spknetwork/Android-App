
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/video_details_screen/new_video_details_info.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/routes/routes.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
                context.pushNamed(Routes.userView, pathParameters: {'author': author});
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
                    context.pushNamed(Routes.userView, pathParameters: {'author':  author});
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
            var screen = NewVideoDetailsInfo(appData: context.read<HiveUserData>(),item: widget.gqlFeedItem,);
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
