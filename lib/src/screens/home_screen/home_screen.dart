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

  @override
  void initState() {
    super.initState();
    vm = HomeScreenViewModel(
        path: widget.path,
        stateUpdated: () {
          setState(() {});
        });
    vm.loadHomeFeed();
  }

  void onTap(HomeFeedItem item) {
    Navigator.of(context).pushNamed(VideoDetailsScreen.routeName,
        arguments: VideoDetailsScreenArguments(item));
  }

  Widget _screen() {
    return vm.state == LoadState.loading
        ? widgets.loadingData()
        : vm.state == LoadState.failed
            ? RetryScreen(error: vm.error, onRetry: vm.loadHomeFeed)
            : widgets.list(vm.list, vm.loadHomeFeed, onTap);
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
