import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed_models.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDataFetched = false;
  List<HomeFeed> list = [];
  final widgets = HomeScreenWidgets();

  Future _loadHomeFeed() async {
    final endPoint = "${server.domain}/api/feed/more";
    var response = await get(Uri.parse(endPoint));
    List<HomeFeed> list = homeFeedFromJson(response.body);
    setState(() {
      isDataFetched = true;
      this.list = list;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHomeFeed();
  }

  Widget _screen() {
    return isDataFetched ? widgets.list(list) : widgets.loadingData();
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
