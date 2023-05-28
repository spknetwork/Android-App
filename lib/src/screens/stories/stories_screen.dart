import 'package:acela/src/screens/stories/new_stories_feed.dart';
import 'package:acela/src/screens/stories/stories_feed.dart';
import 'package:flutter/material.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  static List<Tab> tabs = [
    Tab(icon: const Icon(Icons.home)),
    // Tab(icon: const Icon(Icons.trending_up)),
    // Tab(icon: const Icon(Icons.new_label)),
    Tab(child: Image.asset('assets/ctt-logo.png')),
  ];
  var fitWidth = true;

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
                NewStoriesFeedScreen(),
                StoriesFeedScreen(
                  type: 'new',
                  height: height,
                  fitWidth: fitWidth,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
