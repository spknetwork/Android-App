import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/graphql/gql_communicator.dart';
import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/about/about_home_screen.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/leaderboard_screen/leaderboard_screen.dart';
import 'package:acela/src/screens/my_account/my_account_screen.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/gql_feed_list_item.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/new_feed_list_item.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:acela/src/widgets/shorts_xlist_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' show get;

class GQLFeedScreen extends StatefulWidget {
  const GQLFeedScreen({Key? key});

  @override
  State<GQLFeedScreen> createState() => _GQLFeedScreenState();
}

class _GQLFeedScreenState extends State<GQLFeedScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<HomeFeedItem>> loadHome;
  late Future<List<HomeFeedItem>> loadTrending;
  late Future<List<HomeFeedItem>> loadNew;
  late Future<List<HomeFeedItem>> loadFirstUploads;

  var urls = [
    "${server.domain}/apiv2/feeds/Home",
    "${server.domain}/apiv2/feeds/trending",
    "${server.domain}/apiv2/feeds/new",
    "${server.domain}/apiv2/feeds/firstUploads",
  ];

  static const List<Tab> myTabs = <Tab>[
    Tab(icon: Icon(Icons.person)),
    Tab(icon: Icon(Icons.home)),
    Tab(icon: Icon(Icons.local_fire_department)),
    Tab(icon: Icon(Icons.play_arrow)),
    Tab(icon: Icon(Icons.emoji_emotions)),
    Tab(icon: Icon(Icons.handshake)),
    Tab(icon: Icon(Icons.leaderboard)),
  ];

  late TabController _tabController;
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
    loadHome = _loadFeed(urls[0]);
    loadTrending = _loadFeed(urls[1]);
    loadNew = _loadFeed(urls[2]);
    loadFirstUploads = _loadFeed(urls[3]);
  }

  Future<List<HomeFeedItem>> _loadFeed(String url) async {
    var response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw 'Status code ${response.statusCode}';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void reloadWithIndex(int index) {
    setState(() {
      if (index == 0) {
        loadHome = _loadFeed(urls[0]);
      } else if (index == 1) {
        loadTrending = _loadFeed(urls[1]);
      } else if (index == 2) {
        loadNew = _loadFeed(urls[2]);
      } else if (index == 3) {
        loadFirstUploads = _loadFeed(urls[3]);
      }
    });
  }

  Widget futureBuilderForTrending(int index, HiveUserData data) {
    return FutureBuilder(
      future: (index == 0)
          ? loadHome
          : (index == 1)
              ? loadTrending
              : (index == 2)
                  ? loadNew
                  : loadFirstUploads,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: RetryScreen(
              error: snapshot.error?.toString() ?? 'Something went wrong',
              onRetry: () {
                reloadWithIndex(index);
              },
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          var list = snapshot.data as List<HomeFeedItem>;
          var shorts = list.where((element) => element.duration <= 90).toList();
          return ListView.separated(
            itemBuilder: (c, i) {
              return NewFeedListItem(
                rpc: data.rpc,
                thumbUrl: server.resizedImage(list[i].images.thumbnail),
                author: list[i].author,
                title: list[i].title,
                createdAt: list[i].createdAt,
                duration: list[i].duration,
                views: list[i].views,
                permlink: list[i].permlink,
                onTap: () {},
                onUserTap: () {},
              );
            },
            separatorBuilder: (c, i) =>
                const Divider(color: Colors.transparent),
            itemCount: list.length,
          );
        } else {
          return LoadingScreen(
            title: 'Loading Data',
            subtitle: 'Please wait...',
          );
        }
      },
    );
  }

  String getSubtitle() {
    switch (currentIndex) {
      case 0:
        return 'User Feed';
      case 1:
        return 'Home Feed';
      case 2:
        return 'Trending Feed';
      case 3:
        return 'New Feed';
      case 4:
        return 'First Uploads';
      case 5:
        return 'Communities';
      case 6:
        return 'Leaderboard';
      default:
        return 'User Feed';
    }
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: InkWell(
            child: CircleAvatar(
              child: ClipOval(
                  child: Image.asset('assets/branding/three_speak_icon.png',
                      height: 40, width: 40)),
              radius: 20,
            ),
            onTap: () {
              var screen = const AboutHomeScreen();
              var route = MaterialPageRoute(builder: (_) => screen);
              Navigator.of(context).push(route);
            },
          ),
          title: Text('3Speak.tv'),
          subtitle: Text(getSubtitle()),
        ),
        actions: [
          IconButton(
            onPressed: () {
              var route = MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              );
              Navigator.of(context).push(route);
            },
            icon: const Icon(Icons.search),
          ),
          if (appData.username != null)
            IconButton(
              onPressed: () {
                // uploadClicked(appData);
              },
              icon: const Icon(Icons.upload),
            ),
          if (appData.username != null)
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (c) => MyAccountScreen(data: appData),
                  ),
                );
              },
              icon: CustomCircleAvatar(
                height: 36,
                width: 36,
                url:
                    'https://images.hive.blog/u/${appData.username ?? ''}/avatar',
              ),
            )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          appData.username != null
              ? Center(child: Text(appData.username!))
              : Center(child: Text('Please log in')),
          futureBuilderForTrending(0, appData),
          futureBuilderForTrending(1, appData),
          futureBuilderForTrending(2, appData),
          futureBuilderForTrending(3, appData),
          CommunitiesScreen(
            didSelectCommunity: null,
            withoutScaffold: true,
          ),
          LeaderboardScreen(withoutScaffold: true),
        ],
      ),
    );
  }
}
