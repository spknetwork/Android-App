import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreenWidgets {
  Widget loadingData() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: const Center(
        child: Text('Loading Data'),
      ),
    );
  }

  Widget _tileTitle(HomeFeed item, BuildContext context) {
    String timeInString = "📆 ${timeago.format(item.created)}";
    String owner = "👤 ${item.owner}";
    String duration = "🕚 ${Utilities.formatTime(item.duration.toInt())}";
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.thumbUrl,
      userThumbUrl: server.userOwnerThumb(item.owner),
      title: item.title,
      subtitle: "$timeInString $owner $duration",
    );
  }

  Widget _listTile(HomeFeed item, BuildContext context) {
    return ListTile(
      title: _tileTitle(item, context),
      onTap: () {
        debugPrint("Hello world");
      },
    );
  }

  Widget list(List<HomeFeed> list, Future<void> Function() onRefresh) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return _listTile(list[index], context);
            },
            separatorBuilder: (context, index) => const Divider(
              thickness: 0,
              height: 10,
              color: Colors.transparent,
            ),
            itemCount: list.length),
      )
    );
  }
}
