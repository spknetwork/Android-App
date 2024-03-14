import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/video_upload_sheet.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/my_account/my_account_screen.dart';
import 'package:acela/src/screens/podcast/view/podcast_trending.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/stories/new_tab_based_stories.dart';
import 'package:acela/src/screens/upload/podcast/podcast_upload_screen.dart';
import 'package:acela/src/screens/upload/video/controller/video_upload_controller.dart';
import 'package:acela/src/screens/upload/video/video_upload_screen.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({required this.appData, this.username});

  final HiveUserData appData;
  final String? username;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 65,
      child: BottomNavigationBar(
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SizedBox(height: 25, child: Icon(Icons.search)),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Image.asset(
                  'assets/branding/three_shorts_icon.png',
                  height: 23,
                  width: 23,
                ),
              ),
            ),
            label: '3Shorts',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(height: 25, child: Icon(Icons.add)),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              child: Image.asset(
                'assets/pod-cast-logo-round.png',
                height: 23,
                width: 23,
              ),
            ),
            label: 'Podcast',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
                height: 25,
                child: widget.username == null
                    ? Icon(Icons.person)
                    : CustomCircleAvatar(
                        height: 23,
                        width: 23,
                        url:
                            'https://images.hive.blog/u/${widget.username ?? ''}/avatar',
                      )),
            label: 'You',
          ),
        ],
        onTap: (index) => navigate(index, context),
        selectedItemColor: theme.primaryColorLight,
        unselectedItemColor: theme.primaryColorLight,
        backgroundColor: theme.primaryColorDark,
      ),
    );
  }

  void navigate(int index, BuildContext context) {
    switch (index) {
      case 0:
        _onTapSearch();
        break;
      case 1:
        _onTapThreeShorts();
        break;
      case 2:
        _uploadBottomSheet();
        break;
      case 3:
        _onTapPodcast();
        break;
      case 4:
        _onAccountTap();
        break;
    }
  }

  void _onTapThreeShorts() {
    var screen = GQLStoriesScreen(appData: widget.appData);
    var route = MaterialPageRoute(builder: (c) => screen);
    Navigator.of(context).push(route);
  }

  Widget addPostButton(HiveUserData? userData) {
    return Visibility(
      visible: widget.username != null,
      child: SizedBox(
          width: 40,
          child: IconButton(
            color: Theme.of(context).primaryColorLight,
            onPressed: () {
              _uploadBottomSheet();
            },
            icon: Icon(Icons.add_circle),
          )),
    );
  }

  void _onTapPodcast() {
    var screen = PodCastTrendingScreen(appData: widget.appData);
    var route = MaterialPageRoute(builder: (c) => screen);
    Navigator.of(context).push(route);
  }

  void _onTapSearch() {
    var route = MaterialPageRoute(
      builder: (context) => const SearchScreen(),
    );
    Navigator.of(context).push(route);
  }

  void _onAccountTap() {
    if (widget.username == null) {
      _loginBottomSheet();
      return;
    } else {
      var screen = MyAccountScreen(data: widget.appData);
      var route = MaterialPageRoute(builder: (c) => screen);
      Navigator.of(context).push(route);
    }
  }

  void _loginBottomSheet() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('You are not logged in. Please log in.'),
      androidBorderRadius: 30,
      actions: [
        BottomSheetAction(
            title: Text('Log in'),
            leading: Icon(Icons.login),
            onPressed: (c) {
              Navigator.of(c).pop();
              var screen = HiveAuthLoginScreen(appData: widget.appData);
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(c).push(route);
            }),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  void _uploadBottomSheet() {
    if (widget.username == null) {
      _loginBottomSheet();
    } else {
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
                  appData: widget.appData,
                );
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              } else {
                VideoUploadSheet.show(widget.appData, context);
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
}
