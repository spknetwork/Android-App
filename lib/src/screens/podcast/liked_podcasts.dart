import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/podcast_trending.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LikedPodcasts extends StatefulWidget {
  const LikedPodcasts({Key? key, required this.appData})
      : super(key: key);

  final HiveUserData appData;

  @override
  State<LikedPodcasts> createState() => _LikedPodcastsState();
}

class _LikedPodcastsState extends State<LikedPodcasts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( "Liked Podcasts"),
      ),
      body: items().isEmpty
          ? Center(
              child: Text(
                  "Liked Podcasts is Empty"))
          : ListView.separated(
              itemBuilder: (c, i) {
                var title = items()[i].title ?? 'No title';
                var desc = '';
                desc =
                    "$desc${(items()[i].categories?.values ?? []).join(", ")}";
                return PodcastFeedItemWidget(
                  showLikeButton: false,
                  appData: widget.appData,
                  item: items()[i],
                );
              },
              separatorBuilder: (c, i) => const Divider(height: 0),
              itemCount: items().length,
            ),
    );
 
  }

  List<PodCastFeedItem> items() {
    final box = GetStorage();
    final String key = 'liked_podcast';
    if (box.read(key) != null) {
      List json = box.read(key);
      List<PodCastFeedItem> items =
          json.map((e) => PodCastFeedItem.fromJson(e)).toList();
      return items;
    } else {
      return [];
    }
  }
}
