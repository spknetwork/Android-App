import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/about/about_home_screen.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_list.dart';
import 'package:acela/src/screens/leaderboard_screen/leaderboard_screen.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/my_account/my_account_screen.dart';
import 'package:acela/src/screens/podcast/view/podcast_trending.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/settings/settings_screen.dart';
import 'package:acela/src/screens/stories/new_tab_based_stories.dart';
import 'package:acela/src/screens/trending_tags/trending_tags.dart';
import 'package:acela/src/screens/upload/new_video_upload_screen.dart';
import 'package:acela/src/widgets/fab_custom.dart';
import 'package:acela/src/widgets/fab_overlay.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class GQLFeedScreen extends StatefulWidget {
  const GQLFeedScreen({
    Key? key,
    required this.appData,
    required this.username,
  });

  final HiveUserData appData;
  final String? username;

  @override
  State<GQLFeedScreen> createState() => _GQLFeedScreenState();
}

class _GQLFeedScreenState extends State<GQLFeedScreen>
    with SingleTickerProviderStateMixin {

  var isMenuOpen = false;

  List<Tab> myTabs() {
    return widget.username != null ? <Tab>[
      Tab(icon: Icon(Icons.person)),
      // Tab(icon: Icon(Icons.home)),
      Tab(icon: Icon(Icons.local_fire_department)),
      Tab(icon: Icon(Icons.play_arrow)),
      Tab(icon: Icon(Icons.looks_one)),
      Tab(icon: Icon(Icons.handshake)),
      Tab(icon: Icon(Icons.tag)),
    ] : <Tab>[
      // Tab(icon: Icon(Icons.home)),
      Tab(icon: Icon(Icons.local_fire_department)),
      Tab(icon: Icon(Icons.play_arrow)),
      Tab(icon: Icon(Icons.looks_one)),
      Tab(icon: Icon(Icons.handshake)),
      Tab(icon: Icon(Icons.tag)),
    ];
  }

  late TabController _tabController;
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: widget.username != null ? 6 : 5);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String getSubtitle() {
    if (widget.username != null) {
      switch (currentIndex) {
        case 0:
          return '@${widget.username ?? 'User'}\'s feed';
        case 1:
          return 'Trending feed';
        case 2:
          return 'New feed';
        case 3:
          return 'First uploads';
        case 4:
          return 'Communities';
        case 5:
          return 'Trending Tags';
        default:
          return 'User\'s feed';
      }
    } else {
      switch (currentIndex) {
        case 0:
          return 'Trending feed';
        case 1:
          return 'New feed';
        case 2:
          return 'First uploads';
        case 3:
          return 'Communities';
        case 4:
          return 'Trending Tags';
        default:
          return 'User\'s feed';
      }
    }
  }

  Widget appBarHeader() {
    return ListTile(
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
    );
  }

  IconButton threeShortsActionButton() {
    return IconButton(
      onPressed: () {
        var screen = GQLStoriesScreen(appData: widget.appData);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
      icon: Image.asset(
        'assets/branding/three_shorts_icon.png',
      ),
    );
  }

  IconButton podcastsActionButton() {
    return IconButton(
      onPressed: () {
        var screen = PodCastTrendingScreen(appData: widget.appData);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
      icon: Image.asset(
        'assets/pod-cast-logo-round.png',
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: appBarHeader(),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs(),
          isScrollable: true,
        ),
        actions: [
          threeShortsActionButton(),
          podcastsActionButton(),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            TabBarView(
                controller: _tabController,
                children: widget.username != null ? [
                  HomeScreenFeedList(feedType: HomeScreenFeedType.userFeed, appData: appData),
                  HomeScreenFeedList(feedType: HomeScreenFeedType.trendingFeed, appData: appData),
                  HomeScreenFeedList(feedType: HomeScreenFeedType.newUploads, appData: appData),
                  HomeScreenFeedList(feedType: HomeScreenFeedType.firstUploads, appData: appData),
                  CommunitiesScreen(
                    didSelectCommunity: null,
                    withoutScaffold: true,
                  ),
                  TrendingTagsWidget(),
                ] : [
                  HomeScreenFeedList(feedType: HomeScreenFeedType.trendingFeed, appData: appData),
                  HomeScreenFeedList(feedType: HomeScreenFeedType.newUploads, appData: appData),
                  HomeScreenFeedList(feedType: HomeScreenFeedType.firstUploads, appData: appData),
                  CommunitiesScreen(
                    didSelectCommunity: null,
                    withoutScaffold: true,
                  ),
                  TrendingTagsWidget(),
                ]
            ),
            _fabContainer()
          ],
        ),
      ),
    );
  }

  List<FabOverItemData> _fabItems() {
    var podcast = FabOverItemData(
      displayName: 'Podcasts',
      icon: Icons.video_camera_front_outlined,
      image: 'assets/pod-cast-logo-round.png',
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var screen = PodCastTrendingScreen(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        });
      },
    );
    var threeShorts = FabOverItemData(
      displayName: '3Shorts',
      icon: Icons.video_camera_front_outlined,
      image: 'assets/branding/three_shorts_icon.png',
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var screen = GQLStoriesScreen(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        });
      },
    );
    var search = FabOverItemData(
      displayName: 'Search',
      icon: Icons.search,
      onTap: () {
        setState(() {
          isMenuOpen = false;
          var route = MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          );
          Navigator.of(context).push(route);
        });
      },
    );
    var fabItems = [podcast, threeShorts, search];
    if (widget.username != null) {
      fabItems.add(
        FabOverItemData(
          displayName: 'Upload',
          icon: Icons.upload,
          onTap: () {
            setState(() {
              isMenuOpen = false;
              uploadClicked(widget.appData);
            });
          },
        ),
      );
      fabItems.add(
        FabOverItemData(
          displayName: 'My Account',
          icon: Icons.person,
          url:
          'https://images.hive.blog/u/${widget.username ?? ''}/avatar',
          onTap: () {
            setState(() {
              isMenuOpen = false;
              var screen = MyAccountScreen(data: widget.appData);
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            });
          },
        ),
      );
    } else {
      fabItems.add(
        FabOverItemData(
          displayName: 'Log in',
          icon: Icons.person,
          onTap: () {
            setState(() {
              isMenuOpen = false;
              var screen = HiveAuthLoginScreen(appData: widget.appData);
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            });
          },
        ),
      );
    }
    fabItems.add(
      FabOverItemData(
        displayName: 'Important 3Speak Links',
        icon: Icons.link,
        onTap: () {
          setState(() {
            isMenuOpen = false;
            var screen = const AboutHomeScreen();
            var route = MaterialPageRoute(builder: (_) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
    );
    fabItems.add(
      FabOverItemData(
        displayName: 'Settings',
        icon: Icons.settings,
        onTap: () {
          setState(() {
            isMenuOpen = false;
            var screen = const SettingsScreen();
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          });
        },
      ),
    );
    fabItems.add(
      FabOverItemData(
        displayName: 'Close',
        icon: Icons.close,
        onTap: () {
          setState(() {
            isMenuOpen = false;
          });
        },
      ),
    );
    return fabItems;
  }

  Widget _fabContainer() {
    if (!isMenuOpen) {
      return FabCustom(
        icon: Icons.bolt,
        onTap: () {
          setState(() {
            isMenuOpen = true;
          });
        },
      );
    }
    return FabOverlay(
      items: _fabItems(),
      onBackgroundTap: () {
        setState(() {
          isMenuOpen = false;
        });
      },
    );
  }

  void uploadClicked(HiveUserData data) {
    if (data.username != null && data.postingKey != null) {
      showBottomSheetForRecordingTypes(data);
    } else if (data.keychainData != null) {
      var expiry = data.keychainData!.hasExpiry;
      log('Expiry is $expiry');
      try {
        var longValue = int.tryParse(expiry) ?? 0;
        var expiryDate = DateTime.fromMillisecondsSinceEpoch(longValue);
        var nowDate = DateTime.now();
        log('Expiry Date is $expiryDate, now date is $nowDate');
        var compareResult = nowDate.compareTo(expiryDate);
        log('compare result - $compareResult');
        if (compareResult == -1) {
          showBottomSheetForRecordingTypes(data);
        } else {
          showError('Invalid Session. Please login again.');
          logout(data);
        }
      } catch (e) {
        showError('Invalid Session. Please login again.');
        logout(data);
      }
    } else {
      showError('Invalid Session. Please login again.');
      logout(data);
    }
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showBottomSheetForVideoOptions(bool isReel, HiveUserData data) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('How do you want to upload?'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('Camera'),
          leading: const Icon(Icons.camera_alt),
          onPressed: (c) {
            var screen = NewVideoUploadScreen(
              camera: true,
              data: data,
            );
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).pop();
            Navigator.of(context).push(route);
          },
        ),
        BottomSheetAction(
            title: const Text('Photo Gallery'),
            leading: const Icon(Icons.photo_library),
            onPressed: (c) {
              var screen = NewVideoUploadScreen(
                camera: false,
                data: data,
              );
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).pop();
              Navigator.of(context).push(route);
            }),
      ],
      cancelAction: CancelAction(
        title: const Text('Cancel'),
      ),
    );
  }

  void showBottomSheetForRecordingTypes(HiveUserData data) {
    showBottomSheetForVideoOptions(false, data);
  }

  void logout(HiveUserData data) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'postingKey');
    await storage.delete(key: 'cookie');
    await storage.delete(key: 'hasId');
    await storage.delete(key: 'hasExpiry');
    await storage.delete(key: 'hasAuthKey');
    String resolution = await storage.read(key: 'resolution') ?? '480p';
    String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
    String? lang = await storage.read(key: 'lang');
    server.updateHiveUserData(
      HiveUserData(
        username: null,
        postingKey: null,
        keychainData: null,
        cookie: null,
        resolution: resolution,
        rpc: rpc,
        loaded: true,
        language: lang,
      ),
    );
  }
}
