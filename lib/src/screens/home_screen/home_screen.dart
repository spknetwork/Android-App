import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_view_model.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final widgets = HomeScreenWidgets();
  final HomeScreenViewModel vm = HomeScreenViewModel();

  void onTap(HomeFeed item) {
    Navigator.of(context).pushNamed(VideoDetailsScreen.routeName,
        arguments: VideoDetailsScreenArguments(item));
  }

  Widget _screen() {
    return FutureBuilder(
      future: vm.getHomeFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return RetryScreen(
                error: snapshot.error as String, onRetry: vm.getHomeFeed);
          } else if (snapshot.hasData) {
            return widgets.list(
                snapshot.data as List<HomeFeed>, vm.getHomeFeed, onTap);
          } else {
            return widgets.loadingData();
          }
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
        title: const Text('Home'),
      ),
      body: _screen(),
      drawer: const DrawerScreen(),
    );
  }
}
