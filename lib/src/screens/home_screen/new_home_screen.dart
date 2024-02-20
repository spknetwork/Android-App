
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/about/about_home_screen.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/favourites/user_favourites.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/tab_title_toast.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_list.dart';
import 'package:acela/src/screens/home_screen/video_upload_sheet.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/my_account/my_account_screen.dart';
import 'package:acela/src/screens/podcast/view/podcast_trending.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/settings/settings_screen.dart';
import 'package:acela/src/screens/stories/new_tab_based_stories.dart';
import 'package:acela/src/screens/trending_tags/trending_tags.dart';
import 'package:acela/src/screens/upload/podcast/podcast_upload_screen.dart';
import 'package:acela/src/screens/upload/video/controller/video_upload_controller.dart';
import 'package:acela/src/screens/upload/video/video_upload_screen.dart';
import 'package:acela/src/widgets/fab_custom.dart';
import 'package:acela/src/widgets/fab_overlay.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

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
    return widget.username != null
        ? <Tab>[
            Tab(icon: Icon(Icons.person)),
            // Tab(icon: Icon(Icons.home)),
            Tab(icon: Icon(Icons.local_fire_department)),
            Tab(icon: Icon(Icons.play_arrow)),
            Tab(icon: Icon(Icons.looks_one)),
            Tab(icon: Icon(Icons.handshake)),
            Tab(icon: Icon(Icons.tag)),
          ]
        : <Tab>[
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
    _tabController =
        TabController(vsync: this, length: widget.username != null ? 6 : 5);
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
      contentPadding: EdgeInsets.zero,
      leading: InkWell(
        child: ClipOval(
            child: Image.asset('assets/branding/three_speak_icon.png',
                height: 33, width: 33)),
        onTap: () {
          var screen = const AboutHomeScreen();
          var route = MaterialPageRoute(builder: (_) => screen);
          Navigator.of(context).push(route);
        },
      ),
      title: Text('3Speak.tv'),
      // subtitle: Text(
      //   getSubtitle(),
      //   maxLines: 1,
      //   overflow: TextOverflow.ellipsis,
      //   style: TextStyle(fontSize: 13),
      // ),
    );
  }

  SizedBox threeShortsActionButton() {
    return SizedBox(
      width: 35,
      child: IconButton(
        onPressed: () {
          var screen = GQLStoriesScreen(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
        icon: Image.asset(
          'assets/branding/three_shorts_icon.png',
          height: 25,
          width: 25,
        ),
      ),
    );
  }

  Widget addPostButton(HiveUserData? userData) {
    return Visibility(
      visible: widget.username != null,
      child: SizedBox(
          width: 40,
          child: IconButton(
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              uploadBottomSheet(userData!);
            },
            icon: Icon(Icons.add_circle),
          )),
    );
  }

  SizedBox podcastsActionButton() {
    return SizedBox(
      width: 35,
      child: IconButton(
        onPressed: () {
          var screen = PodCastTrendingScreen(appData: widget.appData);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
        icon: Image.asset(
          'assets/pod-cast-logo-round.png',
          height: 25,
          width: 25,
        ),
      ),
    );
  }

  SizedBox searchIconButton() {
    return SizedBox(
      width: 40,
      child: IconButton(
        onPressed: () {
          var route = MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          );
          Navigator.of(context).push(route);
        },
        icon: Icon(Icons.search),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return UpgradeAlert(
      upgrader: Upgrader(
        // debugDisplayAlways: true, // for debugging
        showIgnore: true,
        showReleaseNotes: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: appBarHeader(),
          bottom: TabBar(
            controller: _tabController,
            tabs: myTabs(),
          ),
          actions: [
            searchIconButton(),
            threeShortsActionButton(),
            podcastsActionButton(),
            addPostButton(widget.appData)
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              TabBarView(
                  controller: _tabController,
                  children: widget.username != null
                      ? [
                          HomeScreenFeedList(
                              showVideo: currentIndex == 0,
                              feedType: HomeScreenFeedType.userFeed,
                              appData: appData),
                          HomeScreenFeedList(
                              showVideo: currentIndex == 1,
                              feedType: HomeScreenFeedType.trendingFeed,
                              appData: appData),
                          HomeScreenFeedList(
                              showVideo: currentIndex == 2,
                              feedType: HomeScreenFeedType.newUploads,
                              appData: appData),
                          HomeScreenFeedList(
                              showVideo: currentIndex == 3,
                              feedType: HomeScreenFeedType.firstUploads,
                              appData: appData),
                          CommunitiesScreen(
                            didSelectCommunity: null,
                            withoutScaffold: true,
                          ),
                          TrendingTagsWidget(),
                        ]
                      : [
                          HomeScreenFeedList(
                              showVideo: currentIndex == 0,
                              feedType: HomeScreenFeedType.trendingFeed,
                              appData: appData),
                          HomeScreenFeedList(
                              showVideo: currentIndex == 1,
                              feedType: HomeScreenFeedType.newUploads,
                              appData: appData),
                          HomeScreenFeedList(
                              showVideo: currentIndex == 2,
                              feedType: HomeScreenFeedType.firstUploads,
                              appData: appData),
                          CommunitiesScreen(
                            didSelectCommunity: null,
                            withoutScaffold: true,
                          ),
                          TrendingTagsWidget(),
                        ]),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: HomeScreenTabTitleToast(
                    subtitle: getSubtitle(),
                    tabIndex: currentIndex,
                  ),
                ),
              ),
              _fabContainer()
            ],
          ),
        ),
      ),
    );
  }

  List<FabOverItemData> _fabItems() {
    List<FabOverItemData> fabItems = [];
    if (widget.username != null) {
      fabItems.add(FabOverItemData(
        displayName: 'Upload',
        icon: Icons.upload,
        onTap: () {
          setState(() {
            isMenuOpen = false;
            uploadBottomSheet(widget.appData);
          });
        },
      ));
      fabItems.add(
        FabOverItemData(
          displayName: 'My Account',
          icon: Icons.person,
          url: 'https://images.hive.blog/u/${widget.username ?? ''}/avatar',
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
        displayName: 'Bookmarks',
        icon: Icons.bookmarks,
        onTap: () {
          setState(() {
            isMenuOpen = false;
            var screen = const UserFavourites();
            var route = MaterialPageRoute(builder: (c) => screen);
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

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void uploadBottomSheet(HiveUserData data) {
    showAdaptiveActionSheet(
      context: context,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload),
          const SizedBox(
            width: 5,
          ),
          const Text(
            'Upload',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('Video'),
          leading: const Icon(Icons.video_call),
          onPressed: (c) {
            Navigator.pop(context);
            if (!context.read<VideoUploadController>().isFreshUpload()) {
              var screen = VideoUploadScreen(
                isCamera: true,
                appData: data,
              );
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            } else {
              VideoUploadSheet.show(data, context);
            }
          },
        ),
        BottomSheetAction(
            title: const Text('Podcast'),
            leading: const Icon(Icons.podcasts),
            onPressed: (c) {
              var route = MaterialPageRoute(
                  builder: (c) => PodcastUploadScreen(data: widget.appData));
              Navigator.of(context).pop();
              Navigator.of(context).push(route);
            }),
      ],
      cancelAction: CancelAction(
        title: const Text('Cancel'),
      ),
    );
  }
}
