import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/view/liked_podcasts.dart';
import 'package:acela/src/screens/podcast/view/local_podcast_episode.dart';
import 'package:acela/src/screens/podcast/view/podcast_search.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_feed_item.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import '../../../widgets/fab_custom.dart';
import '../../../widgets/fab_overlay.dart';

class PodCastTrendingScreen extends StatefulWidget {
  const PodCastTrendingScreen({
    Key? key,
    required this.appData,
  });

  final HiveUserData appData;

  @override
  State<PodCastTrendingScreen> createState() => _PodCastTrendingScreenState();
}

class _PodCastTrendingScreenState extends State<PodCastTrendingScreen> {
  bool isMenuOpen = false;
  late Future<TrendingPodCastResponse> future;

  @override
  void initState() {
    super.initState();
    future = PodCastCommunicator().getTrendingPodcasts();
  }

  Widget getList(List<PodCastFeedItem> items) {
    return ListView.separated(
      itemBuilder: (c, i) {
        return PodcastFeedItemWidget(
          appData: widget.appData,
          item: items[i],
        );
      },
      separatorBuilder: (c, i) => const Divider(height: 0),
      itemCount: items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Image.asset(
            'assets/pod-cast-logo-round.png',
            width: 40,
            height: 40,
          ),
          title: Text('Podcasts'),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return RetryScreen(
                  error: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      future = PodCastCommunicator().getTrendingPodcasts();
                    });
                  },
                );
              } else if (snapshot.connectionState == ConnectionState.done) {
                var data = snapshot.data as TrendingPodCastResponse;
                var list = data.feeds ?? [];
                if (list.isEmpty) {
                  return RetryScreen(
                    error: 'No data found.',
                    onRetry: () {
                      setState(() {
                        future = PodCastCommunicator().getTrendingPodcasts();
                      });
                    },
                  );
                } else {
                  return getList(list);
                }
              } else {
                return LoadingScreen(
                    title: 'Loading', subtitle: 'Please wait..');
              }
            },
          ),
          _fabContainer()
        ],
      ),
    );
  }

  Widget _fabContainer() {
    if (!isMenuOpen) {
      return FabCustom(
        icon: Icons.bolt,
        onTap: () {
          setState(() {
            isMenuOpen = true;
          });
        },
      );
    }
    return FabOverlay(
      items: _fabItems(),
      onBackgroundTap: () {
        setState(() {
          isMenuOpen = false;
        });
      },
    );
  }

  List<FabOverItemData> _fabItems() {
    var search = FabOverItemData(
      displayName: 'Search',
      icon: Icons.search,
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var screen = PodCastSearch(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        });
      },
    );
    var favourites = FabOverItemData(
      displayName: 'Favourites',
      icon: Icons.favorite,
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var screen = LikedPodcasts(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        });
      },
    );
    var downloaded = FabOverItemData(
      displayName: 'Downloaded Podcast Episode',
      icon: Icons.download_rounded,
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var screen = LocalPodcastEpisode(
            appData: widget.appData,
          );
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        });
      },
    );
    var close = FabOverItemData(
      displayName: 'Close',
      icon: Icons.close,
      onTap: () {
        setState(() {
          isMenuOpen = false;
        });
      },
    );
    var fabItems = [downloaded, favourites, search, close];

    return fabItems;
  }
}

