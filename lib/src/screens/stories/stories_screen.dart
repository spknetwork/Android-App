import 'package:acela/src/screens/stories/stories_feed.dart';
import 'package:flutter/material.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({Key? key}) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  static const List<Tab> tabs = [
    Tab(icon: const Icon(Icons.home)),
    Tab(icon: const Icon(Icons.trending_up)),
    Tab(icon: const Icon(Icons.new_label)),
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
            // actions: [
            //   fitWidth
            //       ? IconButton(
            //           onPressed: () {
            //             setState(() {
            //               fitWidth = false;
            //             });
            //           },
            //           icon: Icon(Icons.screenshot))
            //       : IconButton(
            //           onPressed: () {
            //             setState(() {
            //               fitWidth = true;
            //             });
            //           },
            //           icon: Icon(Icons.smart_screen),
            //         )
            // ],
            bottom: TabBar(
              tabs: tabs,
            ),
          );
          var height = appBar.preferredSize.height;
          return Scaffold(
            appBar: appBar,
            body: TabBarView(
              children: [
                StoriesFeedScreen(
                  type: 'feed',
                  height: height,
                  fitWidth: fitWidth,
                ),
                StoriesFeedScreen(
                  type: 'trends',
                  height: height,
                  fitWidth: fitWidth,
                ),
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
