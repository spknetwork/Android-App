import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreenWidgets {
  Widget loadingData() {
    return const LoadingScreen(
      title: 'Loading Data',
      subtitle: 'Please wait',
    );
  }

  Widget _tileTitle(
    HomeFeedItem item,
    BuildContext context,
    Function(HomeFeedItem) onUserTap,
    Map<String, PayoutInfo?> payout,
  ) {
    String timeInString =
        item.createdAt != null ? "📆 ${timeago.format(item.createdAt!)}" : "";
    String duration = "🕚 ${Utilities.formatTime(item.duration.toInt())}";
    String views = "▶ ${item.views}";
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.images.thumbnail,
      userThumbUrl: server.userOwnerThumb(item.author),
      title: item.title,
      subtitle: "$timeInString $duration $views",
      onUserTap: () {
        onUserTap(item);
      },
      user: item.author,
      permlink: item.permlink,
      shouldResize: true,
      isIpfs: item.playUrl.contains('ipfs'),
    );
  }

  Widget _listTile(
    HomeFeedItem item,
    BuildContext context,
    Function(HomeFeedItem) onTap,
    Function(HomeFeedItem) onUserTap,
    Map<String, PayoutInfo?> payout,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: _tileTitle(item, context, onUserTap, payout),
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget list(
    List<HomeFeedItem> list,
    Function(HomeFeedItem) onTap,
    Function(HomeFeedItem) onUserTap,
    Map<String, PayoutInfo?> payout,
  ) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return _listTile(list[index], context, onTap, onUserTap, payout);
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 0, height: 15, color: Colors.transparent),
      itemCount: list.length,
    );
  }
}
