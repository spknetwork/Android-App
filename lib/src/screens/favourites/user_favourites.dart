import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/favourites/favourite_shorts_body.dart';
import 'package:acela/src/screens/favourites/favourite_tags_body.dart';
import 'package:acela/src/screens/favourites/favourite_video_body.dart';
import 'package:acela/src/screens/podcast/view/liked_podcasts.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UserFavourites extends StatefulWidget {
  const UserFavourites({Key? key}) : super(key: key);

  @override
  State<UserFavourites> createState() => _UserFavouritesState();
}

class _UserFavouritesState extends State<UserFavourites>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    var text = currentIndex == 0
        ? 'Videos'
        : currentIndex == 1
            ? 'Shorts'
            : currentIndex == 2
                ? 'Tags'
                : 'Podcasts';
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text('Favourites'),
          subtitle: Text(text),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.play_arrow)),
            Tab(icon: const Icon(Icons.video_library_rounded)),
            Tab(icon: const Icon(Icons.tag)),
            Tab(icon: const Icon(Icons.podcasts)),
            Tab(icon: const Icon(FontAwesomeIcons.rss)),
          ],
        ),
      ),
      body: TabBarView(controller: _tabController, children: [
        FavouriteVideoBody(appData: appData),
        FavouriteShortsBody(
          appData: appData,
        ),
        FavouriteTagsBody(),
        LikedPodcasts(
          appData: appData,
          showAppBar: false,
        ),
        LikedPodcasts(
          appData: appData,
          showAppBar: false,
          filterOnlyRssPodcasts: true,
        )
      ]),
    );
  }
}
