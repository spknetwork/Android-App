import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';

enum LoadState {
  notStarted,
  loading,
  succeeded,
  failed,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LoadState state = LoadState.notStarted;
  List<HomeFeed> list = [];
  final widgets = HomeScreenWidgets();
  String error = 'Something went wrong';

  Future _loadHomeFeed() async {
    setState(() {
      state = LoadState.loading;
    });
    final endPoint = "${server.domain}/api/feed/more";
    var response = await get(Uri.parse(endPoint));
    if (response.statusCode == 200) {
      List<HomeFeed> list = homeFeedFromJson(response.body);
      setState(() {
        state = LoadState.succeeded;
        this.list = list;
      });
    } else {
      setState(() {
        error =
            'Something went wrong.\nStatus code is ${response.statusCode} for $endPoint';
        state = LoadState.failed;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHomeFeed();
  }

  void onTap(HomeFeed item) {
    Navigator.of(context).pushNamed(VideoDetailsScreen.routeName,
        arguments: VideoDetailsScreenArguments(item));
  }

  Widget _screen() {
    return state == LoadState.loading
        ? widgets.loadingData()
        : state == LoadState.failed
            ? RetryScreen(error: error, onRetry: _loadHomeFeed)
            : widgets.list(list, _loadHomeFeed, onTap);
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
