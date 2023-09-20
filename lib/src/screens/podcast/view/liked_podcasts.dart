import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_feed_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikedPodcasts extends StatefulWidget {
  const LikedPodcasts({Key? key, required this.appData}) : super(key: key);

  final HiveUserData appData;

  @override
  State<LikedPodcasts> createState() => _LikedPodcastsState();
}

class _LikedPodcastsState extends State<LikedPodcasts> {
  @override
  Widget build(BuildContext context) {
    final List<PodCastFeedItem> items = context.read<PodcastController>().getLikedPodcast();
    return Scaffold(
      appBar: AppBar(
        title: Text("Liked Podcasts"),
      ),
      body: items.isEmpty
          ? Center(child: Text("Liked Podcasts is Empty"))
          : ListView.separated(
              itemBuilder: (c, i) {
                return PodcastFeedItemWidget(
                  showLikeButton: false,
                  appData: widget.appData,
                  item: items[i],
                );
              },
              separatorBuilder: (c, i) => const Divider(height: 0),
              itemCount: items.length,
            ),
    );
  }
}
