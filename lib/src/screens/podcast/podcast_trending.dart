import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/liked_podcasts.dart';
import 'package:acela/src/screens/podcast/local_podcast_episode.dart';
import 'package:acela/src/screens/podcast/podcast_search.dart';
import 'package:acela/src/screens/podcast/podcasts_feed.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../widgets/fab_custom.dart';
import '../../widgets/fab_overlay.dart';

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
        var title = items[i].title ?? 'No title';
        // title = "$title by ${items[i].author ?? ''}";
        var desc = ''; // items[i].description ?? '';
        desc = "$desc${(items[i].categories?.values ?? []).join(", ")}";
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

class PodcastFeedItemWidget extends StatefulWidget {
  const PodcastFeedItemWidget(
      {Key? key,
      required this.item,
      required this.appData,
      this.showLikeButton = true})
      : super(key: key);

  final PodCastFeedItem item;
  final HiveUserData appData;
  final bool showLikeButton;

  @override
  State<PodcastFeedItemWidget> createState() => _PodcastFeedItemWidgetState();
}

class _PodcastFeedItemWidgetState extends State<PodcastFeedItemWidget> {
  @override
  Widget build(BuildContext context) {
    var title = widget.item.title ?? 'No title';
    var desc = '';
    desc = "$desc${(widget.item.categories?.values ?? []).join(", ")}";
    return ListTile(
      dense: true,
      leading: Image.network(widget.item.image ?? ''),
      title: Text(title),
      subtitle: Text(desc),
      trailing: Visibility(
        visible: widget.showLikeButton,
        child: FavouriteWidget(
            isLiked: isItemPresentLocally(widget.item),
            onAdd: () {
              storeLikedPodcastLocally(widget.item);
            },
            onRemove: () {
              storeLikedPodcastLocally(widget.item);
            }),
      ),
      onTap: () {
        var screen =
            PodcastFeedScreen(appData: widget.appData, item: widget.item);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  bool isItemPresentLocally(PodCastFeedItem item) {
    final box = GetStorage();
    final String key = 'liked_podcast';
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      return index != -1;
    } else {
      return false;
    }
  }

  void storeLikedPodcastLocally(PodCastFeedItem item) {
    final box = GetStorage();
    final String key = 'liked_podcast';
    if (box.read(key) != null) {
      List json = box.read(key);
      int index = json.indexWhere((element) => element['id'] == item.id);
      if (index == -1) {
        json.add(item.toJson());
        box.write(key, json);
      } else {
        json.removeWhere((element) => element['id'] == item.id);
        box.write(key, json);
      }
    } else {
      box.write(key, [item.toJson()]);
    }
    print(box.read(key));
  }
}

class FavouriteWidget extends StatefulWidget {
  const FavouriteWidget(
      {Key? key,
      required this.isLiked,
      required this.onAdd,
      required this.onRemove,
      this.iconColor})
      : super(key: key);

  final bool isLiked;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color? iconColor;

  @override
  State<FavouriteWidget> createState() => _FavouriteWidgetState();
}

class _FavouriteWidgetState extends State<FavouriteWidget> {
  late bool isLiked;
  @override
  void initState() {
    isLiked = widget.isLiked;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FavouriteWidget oldWidget) {
    isLiked = oldWidget.isLiked;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,color: widget.iconColor,),
      onPressed: () {
        if (isLiked) {
          widget.onRemove();
          setState(() {
            isLiked = false;
          });
        } else {
          widget.onAdd();
          setState(() {
            isLiked = true;
          });
        }
      },
    );
  }
}
