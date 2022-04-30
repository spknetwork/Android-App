import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_following.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_profile.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_videos.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

class UserChannelScreen extends StatefulWidget {
  const UserChannelScreen({Key? key, required this.owner}) : super(key: key);
  final String owner;

  @override
  _UserChannelScreenState createState() => _UserChannelScreenState();
}

class _UserChannelScreenState extends State<UserChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  var currentIndex = 0;
  var videoKey = GlobalKey<UserChannelVideosState>();

  static const List<Tab> tabs = [
    Tab(text: 'Videos'),
    Tab(text: 'About'),
    Tab(text: 'Followers'),
    Tab(text: 'Following'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Widget _sortButton() {
    return IconButton(
      onPressed: () {
        _showBottomSheet();
      },
      icon: const Icon(Icons.sort),
    );
  }

  void _showBottomSheet() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Sort by:'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('Newest'),
          onPressed: () {
            videoKey.currentState?.sortByNewest();
          },
        ),
        BottomSheetAction(
          title: const Text('Most Viewed'),
          onPressed: () {
            videoKey.currentState?.sortByMostViewed();
          },
        ),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CustomCircleAvatar(
              height: 40,
              width: 40,
              url: server.userOwnerThumb(widget.owner),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.owner)
          ],
        ),
        actions: currentIndex == 0 ? [_sortButton()] : [],
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          UserChannelVideos(key: videoKey, owner: widget.owner),
          UserChannelProfileWidget(owner: widget.owner),
          UserChannelFollowingWidget(owner: widget.owner, isFollowers: true),
          UserChannelFollowingWidget(owner: widget.owner, isFollowers: false),
        ],
      ),
    );
  }
}
