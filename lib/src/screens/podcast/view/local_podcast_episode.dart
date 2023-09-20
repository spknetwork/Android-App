import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/controller/podcast_controller.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocalPodcastEpisode extends StatelessWidget {
  const LocalPodcastEpisode({Key? key, required this.appData})
      : super(key: key);
  final HiveUserData appData;

  @override
  Widget build(BuildContext context) {
    final podcastController = context.read<PodcastController>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Podcast Episodes'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Offline Episode'),
              Tab(text: 'Liked Episode'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            episodePlayerView(
                podcastController.likedOrOfflinepodcastEpisodes(
                    isOffline: true),
                context,true),
            episodePlayerView(
                podcastController.likedOrOfflinepodcastEpisodes(
                    isOffline: false),
                context,false)
          ],
        ),
      ),
    );
  }

  Widget episodePlayerView(
      List<PodcastEpisode> items, BuildContext context, bool isOffline) {
    if (items.isEmpty)
      return Center(child: Text("${isOffline ? "Offline" : "Liked"} Podcast Episode is Empty"));
    else
      return ListView.separated(
        itemBuilder: (c, index) {
          PodcastEpisode item = items[index];
          return ListTile(
            onTap: () {
              var screen = Scaffold(
                appBar: AppBar(
                  title: ListTile(
                    leading: Image.network(
                      item.image ?? '',
                      width: 40,
                      height: 40,
                    ),
                    title: Text(item.title ?? 'No Title'),
                  ),
                ),
                body: PodcastEpisodePlayer(
                    episodeIndex: index, data: appData, podcastEpisodes: items),
              );
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            },
            leading: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  image: DecorationImage(
                      image: NetworkImage(
                        item.image ?? "",
                      ),
                      fit: BoxFit.cover)),
            ),
            title: Text(
              item.title ?? '',
              maxLines: 2,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          );
        },
        separatorBuilder: (c, i) => const Divider(height: 0),
        itemCount: items.length,
      );
  }
}
