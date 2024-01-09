import 'dart:developer';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/my_account/account_settings/account_settings_screen.dart';
import 'package:acela/src/screens/my_account/update_thumb/update_thumb_screen.dart';
import 'package:acela/src/screens/my_account/update_video/video_primary_info.dart';
import 'package:acela/src/screens/my_account/video_preview.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({
    Key? key,
    required this.data,
  }) : super(key: key);
  final HiveUserData data;

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen>
    with SingleTickerProviderStateMixin {
  Future<List<VideoDetails>>? loadVideos;
  late TabController _tabController;
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      loadVideos = Communicator().loadVideos(widget.data);
    });
    _tabController = TabController(length: 3, vsync: this);
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

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  AppBar _appBar(String username) {
    return AppBar(
      leadingWidth: 30,
      title: ListTile(
        splashColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        onTap: () {
          var screen = UserChannelScreen(owner: username);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
        leading: CustomCircleAvatar(
          height: 36,
          width: 36,
          url: 'https://images.hive.blog/u/$username/avatar',
        ),
        title: Text(
          username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Text('Publish Now')),
          Tab(icon: Text('My Videos')),
          Tab(icon: Text('Others')),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              loadVideos = Communicator().loadVideos(widget.data);
            });
          },
          icon: Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: () {
            var screen = const AccountSettingsScreen();
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          },
          icon: const Icon(Icons.settings),
        )
      ],
    );
  }

  Widget _trailingActionOnVideoListItem(VideoDetails item, HiveUserData user) {
    return item.status == 'published'
        ? const Icon(
            Icons.more_vert,
          )
        : item.status == "encoding_failed" ||
                item.status.toLowerCase() == "deleted"
            ? const Icon(Icons.cancel_outlined, color: Colors.red)
            : item.status == 'publish_manual'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 25,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 0)),
                          onPressed: () {
                            var screen = VideoPrimaryInfo(
                                item: item, justForEditing: false);
                            var route =
                                MaterialPageRoute(builder: (c) => screen);
                            Navigator.of(context).push(route);
                          },
                          child: Text('Publish'),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                padding: EdgeInsets.zero),
                            onPressed: () {
                              _showBottomSheet(item);
                            },
                            child: Center(
                              child: Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.hourglass_top,
                    color: Colors.yellowAccent,
                  );
  }

  void _showBottomSheet(VideoDetails item) {
    var actions = [
      BottomSheetAction(
        title: const Text('Change Thumbnail'),
        onPressed: (context) {
          Navigator.of(context).pop();
          var screen = UpdateThumbScreen(item: item);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ),
    ];
    if (item.status == 'published') {
      actions.add(
        BottomSheetAction(
          title: Text('Play Video'),
          onPressed: (context) {
            Navigator.of(context).pop();
            var vm = VideoDetailsViewModel(
                author: item.owner, permlink: item.permlink);
            var details = VideoDetailsScreen(vm: vm);
            var route = MaterialPageRoute(builder: (_) => details);
            Navigator.of(context).push(route);
          },
        ),
      );
      actions.add(
        BottomSheetAction(
          title: Text('Delete Video'),
          onPressed: (context) async {
            Navigator.of(context).pop();
            showSnackBar('Deleting...', seconds: 60);
            bool result =
                await Communicator().deleteVideo(item.permlink, widget.data);
            hideSnackBar();
            if (result) {
              setState(() {
                loadVideos = Communicator().loadVideos(widget.data);
              });
            } else {
              showSnackBar("Something went wrong");
            }
          },
        ),
      );
    }
    if (item.status == 'publish_manual') {
      actions.add(BottomSheetAction(
        title: Text('Preview'),
        onPressed: (context) {
          Navigator.of(context).pop();
          var screen = VideoPreviewScreen(data: widget.data, item: item);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        },
      ));
    }
    // if (item.status == 'publish_manual') {
    //   actions.add(BottomSheetAction(
    //     title: Text(
    //       'Publish',
    //       style: TextStyle(
    //           color: Colors.green, fontSize: 30, fontWeight: FontWeight.bold),
    //     ),
    //     onPressed: (context) {
    //       Navigator.of(context).pop();
    //       var screen = VideoPrimaryInfo(item: item, justForEditing: false);
    //       var route = MaterialPageRoute(builder: (c) => screen);
    //       Navigator.of(context).push(route);
    //     },
    //   ));
    // }
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Options'),
      androidBorderRadius: 30,
      actions: actions,
      cancelAction: CancelAction(
        title: const Text('Cancel'),
      ),
    );
  }

  void showSnackBar(String message, {int seconds = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deleting..."),
        duration: Duration(seconds: seconds),
      ),
    );
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  Widget _videoListItem(VideoDetails item, HiveUserData user) {
    var desc = item.description.length > 30
        ? item.description.substring(0, 30)
        : item.description;
    // desc = "\n${item.visible_status}";
    return ListTile(
      contentPadding: EdgeInsets.only(right: 10, left: 10),
      leading: Image.network(
        item.getThumbnail(),
      ),
      title: Text(
          item.title.length > 30 ? item.title.substring(0, 30) : item.title),
      subtitle: Text(desc),
      trailing: _trailingActionOnVideoListItem(item, user),
      onTap: () {
        if (item.status != 'publish_manual' &&
            item.status != 'encoding_failed' &&
            item.status.toLowerCase() != 'deleted') {
          _showBottomSheet(item);
        }
      },
    );
  }

  Widget _listViewForItems(List<VideoDetails> items, HiveUserData user) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No Items found.'),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          var text = currentIndex == 0
              ? 'Your videos are ready to post\nTap on a video to edit details & publish'
              : currentIndex == 1
                  ? 'Following videos are already posted\nTap on a video to change thumbnail'
                  : "Here you'll see list of videos which are either in video encoding process or deleted.";
          return Padding(
            padding: const EdgeInsets.only(
                top: 15.0, left: 15, right: 15, bottom: 20),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColorLight),
            ),
          );
        }
        return _videoListItem(items[index - 1], user);
      },
      separatorBuilder: (context, index) => const Divider(
        height: 0,
        color: Colors.transparent,
      ),
      itemCount: items.length + 1,
    );
  }

  Widget _videosList(List<VideoDetails> items, HiveUserData user) {
    log(items.first.created);
    var published = items.where((item) => item.status == 'published').toList();
    var ready = items.where((item) => item.status == 'publish_manual').toList();
    var failed = items
        .where((item) =>
            item.status == 'encoding_failed' ||
            item.status.toLowerCase() == 'Deleted')
        .toList();
    var process = items
        .where((item) =>
            item.status != 'published' &&
            item.status != 'publish_manual' &&
            item.status != 'encoding_failed' &&
            item.status.toLowerCase() != 'deleted')
        .toList();
    var processAndFailed = process + failed;
    processAndFailed.sort((a, b) {
      DateTime dateA = DateTime.parse(a.created);
      DateTime dateB = DateTime.parse(b.created);
      return dateB.compareTo(dateA); // Compare in descending order
    });
    return TabBarView(
      controller: _tabController,
      children: [
        // SafeArea(
        //   child: _listViewForItems(process, user),
        // ),
        SafeArea(
          child: _listViewForItems(ready, user),
        ),
        SafeArea(
          child: _listViewForItems(published, user),
        ),
        SafeArea(
          child: _listViewForItems(processAndFailed, user),
        ),
      ],
    );
  }

  Widget _videoFuture() {
    return FutureBuilder(
      future: loadVideos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return _videosList(snapshot.data as List<VideoDetails>, widget.data);
        } else {
          return const LoadingScreen(
            title: 'Getting your videos',
            subtitle: 'Please wait',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _appBar(widget.data.username ?? 'sagarkothari88'),
        body: SafeArea(
          child: _videoFuture(),
        ),
      ),
    );
  }
}
