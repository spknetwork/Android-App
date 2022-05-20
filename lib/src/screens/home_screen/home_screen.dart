import 'dart:async';
import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show get;

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
  List<HomeFeedItem> items = [];
  var isLoading = false;
  Map<String, PayoutInfo?> payout = {};

  static const platform = MethodChannel('com.example.acela/encoder');

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      isLoading = true;
    });
    var response = await get(Uri.parse(widget.path));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      setState(() {
        isLoading = false;
        items = list;
        var i = 0;
        Timer.periodic(const Duration(seconds: 1), (timer) {
          fetchHiveInfo(list[i].author, list[i].permlink);
          i += 1;
          if (i == list.length) {
            timer.cancel();
          }
        });
      });
    } else {
      showError('Status code ${response.statusCode}');
      setState(() {
        isLoading = false;
        items = [];
      });
    }
  }

  // fetch hive info
  void fetchHiveInfo(String user, String permlink) async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {"author": user, "permlink": permlink, "observer": ""}
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == permlink)
          .first;
      setState(() {
        var upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
        var downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
        payout["$user/$permlink"] = PayoutInfo(
          payout: result.payout,
          downVotes: downVotes,
          upVotes: upVotes,
        );
      });
    } else {
      print(response.reasonPhrase);
    }
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

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _screen() {
    if (isLoading) {
      return widgets.loadingData();
    }
    return widgets.list(items, (item) {
      onTap(item);
    }, (item) {
      onUserTap(item);
    }, payout);
  }

  Widget _fab() {
    return FloatingActionButton(
      onPressed: () async {
        // final String result =
        await platform.invokeMethod('video', {
          'username': 'a',
          'postingKey': 'b',
        });
      },
      child: const Icon(Icons.add),
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
      floatingActionButton: _fab(),
    );
  }
}
