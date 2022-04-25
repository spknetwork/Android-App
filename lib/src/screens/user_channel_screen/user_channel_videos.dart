import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:timeago/timeago.dart' as timeago;

class UserChannelVideos extends StatefulWidget {
  const UserChannelVideos({Key? key, required this.owner}) : super(key: key);
  final String owner;

  @override
  State<UserChannelVideos> createState() => _UserChannelVideosState();
}

class _UserChannelVideosState extends State<UserChannelVideos>
    with AutomaticKeepAliveClientMixin<UserChannelVideos> {
  @override
  bool get wantKeepAlive => true;

  Future<List<HomeFeedItem>> loadFeed(String author) async {
    var response =
        await get(Uri.parse("${server.domain}/apiv2/feeds/@${widget.owner}"));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Widget _tileTitle(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onUserTap) {
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
    );
  }

  Widget _listTile(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onTap, Function(HomeFeedItem) onUserTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: _tileTitle(item, context, onUserTap),
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget _futureVideos() {
    return FutureBuilder(
      future: loadFeed(widget.owner),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading user profile');
        } else if (snapshot.hasData) {
          var data = snapshot.data! as List<HomeFeedItem>;
          return ListView.separated(
            itemBuilder: (context, index) {
              return _listTile(data[index], context, (item) {
                var viewModel = VideoDetailsViewModel(
                    author: item.author, permlink: item.permlink);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VideoDetailsScreen(vm: viewModel)));
              }, (owner) {
                log("tapped on user ${owner.author}");
              });
            },
            separatorBuilder: (context, index) => const Divider(
                thickness: 0, height: 15, color: Colors.transparent),
            itemCount: data.length,
          );
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _futureVideos();
  }
}
