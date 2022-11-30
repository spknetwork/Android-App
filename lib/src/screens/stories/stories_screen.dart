import 'package:acela/src/screens/stories/stories_feed.dart';
import 'package:flutter/material.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  static const List<Tab> tabs = [
    Tab(
      // text: 'Trending',
      icon: const Icon(Icons.local_fire_department),
    ),
    Tab(
      // text: 'New',
      icon: const Icon(Icons.play_arrow),
    ),
    Tab(
      // text: 'First Time',
      icon: const Icon(Icons.emoji_emotions_outlined),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          var appBar = AppBar(
            centerTitle: true,
            title: Row(
              children: [
                Image.asset(
                  "assets/branding/three_shorts_icon.png",
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 15),
                const Text('3Shorts')
              ],
            ),
            bottom: TabBar(
              tabs: tabs,
            ),
          );
          var height = appBar.preferredSize.height;
          return Scaffold(
            appBar: appBar,
            body: TabBarView(
              children: [
                StoriesFeedScreen(type: 'trending', height: height),
                StoriesFeedScreen(type: 'new', height: height),
                StoriesFeedScreen(type: 'firstUploads', height: height),
              ],
            ),
          );
        },
      ),
    );
  }
}
