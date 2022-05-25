import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/login/memo_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_upload/video_upload_login_response.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show get;
import 'package:provider/provider.dart';

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
      });
      var i = 0;
      Timer.periodic(const Duration(seconds: 1), (timer) {
        fetchHiveInfo(list[i].author, list[i].permlink);
        i += 1;
        if (i == list.length) {
          timer.cancel();
        }
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

  Future<String> getAccessToken(
      HiveUserData user, String encryptedToken) async {
    const platform = MethodChannel('com.example.acela/auth');
    final String result = await platform.invokeMethod('encryptedToken', {
      'username': user.username,
      'postingKey': user.postingKey,
      'encryptedToken': encryptedToken,
    });
    var memo = MemoResponse.fromJsonString(result);
    if (memo.error.isNotEmpty) {
      showError('Error ${memo.error}');
      throw memo.error;
    } else if (memo.decrypted.isEmpty) {
      throw 'Decrypted memo is empty';
    }
    return memo.decrypted.replaceFirst("#", '');
  }

  Future<String> getValidCookie(HiveUserData user) async {
    var request = http.Request(
        'GET',
        Uri.parse(
            'http://localhost:13050/mobile/login?username=${user.username}'));
    if (user.cookie != null) {
      Map<String, String> map = {"cookie": user.cookie!};
      request.headers.addAll(map);
    }
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var loginResponse = VideoUploadLoginResponse.fromJsonString(string);
      if (loginResponse.error != null && loginResponse.error!.isNotEmpty) {
        throw 'Error - ${loginResponse.error}';
      } else if (loginResponse.memo != null) {
        var token = await getAccessToken(user, loginResponse.memo!);
        var url =
            'http://localhost:13050/mobile/login?username=${user.username}&access_token=$token';
        var request = http.Request('GET', Uri.parse(url));
        http.StreamedResponse response = await request.send();
        var string = await response.stream.bytesToString();
        var tokenResponse = VideoUploadLoginResponse.fromJsonString(string);
        var cookie = response.headers['set-cookie'];
        if (tokenResponse.error != null && tokenResponse.error!.isNotEmpty) {
          throw 'Error - ${tokenResponse.error}';
        } else if (tokenResponse.network == "hive" &&
            tokenResponse.banned != true &&
            tokenResponse.userId != null &&
            cookie != null &&
            cookie.isNotEmpty) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'cookie', value: cookie);
          var newData = HiveUserData(
            username: user.username,
            postingKey: user.postingKey,
            cookie: cookie,
          );
          server.updateHiveUserData(newData);
          return cookie;
        } else {
          log('This should never happen. No error, no user info. How?');
          throw 'Something went wrong.';
        }
      } else if (loginResponse.network == "hive" &&
          loginResponse.banned != true &&
          loginResponse.userId != null &&
          user.cookie != null) {
        return user.cookie!;
      } else {
        log('This should never happen. No error, no memo, no user info. How?');
        throw 'Something went wrong.';
      }
    } else if (response.statusCode == 500) {
      var string = await response.stream.bytesToString();
      var errorResponse = VideoUploadLoginResponse.fromJsonString(string);
      if (errorResponse.error != null &&
          errorResponse.error!.isNotEmpty &&
          errorResponse.error == 'session expired') {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'cookie');
        var newData = HiveUserData(
          username: user.username,
          postingKey: user.postingKey,
          cookie: null,
        );
        server.updateHiveUserData(newData);
        return await getValidCookie(newData);
      } else {
        throw 'Status code ${response.statusCode}';
      }
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  Widget _fab(HiveUserData user) {
    return FloatingActionButton(
      onPressed: () async {
        try {
          final String result = await platform.invokeMethod('video', {
            'username': user.username,
            'postingKey': user.postingKey,
          });
          log('Result is $result');
          var cookie = await getValidCookie(user);
          log('Cookie is $cookie');
        } catch (e) {
          showError(e.toString());
        }
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
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
      floatingActionButton: user == null ? null : _fab(user),
    );
  }
}
