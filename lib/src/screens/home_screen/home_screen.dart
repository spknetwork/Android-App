import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {Key? key,
      required this.path,
      required this.showDrawer,
      required this.title})
      : super(key: key);
  final String path;
  final bool showDrawer;
  final String title;

  factory HomeScreen.trending() {
    return HomeScreen(
      title: 'Trending Content',
      showDrawer: true,
      path: "${server.domain}/apiv2/feeds/trending",
    );
  }

  factory HomeScreen.home() {
    return HomeScreen(
      title: 'Home',
      showDrawer: true,
      path: "${server.domain}/apiv2/feeds/Home",
    );
  }

  factory HomeScreen.newContent() {
    return HomeScreen(
      title: 'New Content',
      showDrawer: true,
      path: "${server.domain}/apiv2/feeds/new",
    );
  }

  factory HomeScreen.firstUploads() {
    return HomeScreen(
      title: 'First Uploads',
      showDrawer: true,
      path: "${server.domain}/apiv2/feeds/firstUploads",
    );
  }

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
    var viewModel =
        VideoDetailsViewModel(author: item.author, permlink: item.permlink);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => VideoDetailsScreen(vm: viewModel)));
  }

  void onUserTap(HomeFeedItem item) {
    if (!widget.path.contains(item.author)) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (c) => UserChannelScreen(owner: item.author)));
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
        actions: [
          IconButton(
              onPressed: () {
                var route = MaterialPageRoute(
                    builder: (context) => const SearchScreen());
                Navigator.of(context).push(route);
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: _screen(),
      drawer: widget.showDrawer ? const DrawerScreen() : null,
    );
  }
}
