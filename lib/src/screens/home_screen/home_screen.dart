import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {Key? key,
      required this.path,
      required this.showDrawer,
      required this.title,
      required this.isDarkMode,
      required this.switchDarkMode})
      : super(key: key);
  final String path;
  final bool showDrawer;
  final String title;
  final bool isDarkMode;
  final Function switchDarkMode;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final widgets = HomeScreenWidgets();
  late HomeScreenViewModel vm;
  late Future<List<HomeFeedItem>> _loadingFeed;

  @override
  void initState() {
    super.initState();
    vm = HomeScreenViewModel(path: widget.path);
    _loadingFeed = vm.loadHomeFeed();
  }

  void onTap(HomeFeedItem item) {
    Navigator.of(context)
        .pushNamed(VideoDetailsScreen.routeName(item.author, item.permlink));
  }

  void onUserTap(HomeFeedItem item) {
    Navigator.of(context).pushNamed("/userChannel/${item.author}");
  }

  Widget header() {
    if (vm.path.contains("userChannel")) {
      return const SizedBox(
        height: 10,
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }

  Widget _screen() {
    return FutureBuilder(
      future: _loadingFeed,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: vm.loadHomeFeed);
        } else if (snapshot.hasData) {
          List<HomeFeedItem> items = snapshot.data! as List<HomeFeedItem>;
          return widgets.list(items, vm.loadHomeFeed, onTap, onUserTap);
        } else {
          return widgets.loadingData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _screen(),
      drawer: widget.showDrawer
          ? DrawerScreen(
              isDarkMode: widget.isDarkMode,
              switchDarkMode: widget.switchDarkMode,
            )
          : null,
    );
  }
}
