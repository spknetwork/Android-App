import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/screens/my_account/account_settings/account_settings_screen.dart';
import 'package:acela/src/screens/my_account/update_thumb/update_thumb_screen.dart';
import 'package:acela/src/screens/my_account/update_video/video_primary_info.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

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
    _tabController = TabController(length: 4, vsync: this);
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
    var text = currentIndex == 0
        ? 'Videos - in Encoding Process'
        : currentIndex == 1
            ? 'Videos - Ready to post'
            : currentIndex == 2
                ? 'Videos - Already posted'
                : 'Videos - failed to encode';
    return AppBar(
      title: ListTile(
        leading: CustomCircleAvatar(
          height: 36,
          width: 36,
          url: 'https://images.hive.blog/u/$username/avatar',
        ),
        title: Text(username),
        subtitle: Text(text),
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.hourglass_top, color: Colors.yellowAccent)),
          Tab(icon: Icon(Icons.rocket_launch, color: Colors.green)),
          Tab(icon: Icon(Icons.check, color: Colors.blueAccent)),
          Tab(icon: Icon(Icons.cancel_rounded, color: Colors.red)),
        ],
      ),
      actions: [
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
        ? const Icon(Icons.check, color: Colors.blueAccent)
        : item.status == "encoding_failed"
            ? const Icon(Icons.cancel_outlined, color: Colors.red)
            : item.status == 'publish_manual'
                ? IconButton(
                    onPressed: () {
                      var screen = VideoPrimaryInfo(
                        item: item,
                        justForEditing: false,
                      );
                      var route = MaterialPageRoute(builder: (c) => screen);
                      Navigator.of(context).push(route);
                    },
                    icon: const Icon(
                      Icons.rocket_launch,
                      color: Colors.green,
                    ),
                  )
                : const Icon(
                    Icons.hourglass_top,
                    color: Colors.yellowAccent,
                  );
  }

  void _showBottomSheet(VideoDetails item) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Options'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('Change Thumbnail'),
          onPressed: (context) {
            Navigator.of(context).pop();
            var screen = UpdateThumbScreen(item: item);
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          },
        ),
      ],
      cancelAction: CancelAction(
        title: const Text('Cancel'),
      ),
    );
  }

  Widget _videoListItem(VideoDetails item, HiveUserData user) {
    return ListTile(
      leading: Image.network(
        item.thumbUrl,
      ),
      title: Text(item.title),
      subtitle: Text(item.description.length > 30
          ? item.description.substring(0, 30)
          : item.description),
      trailing: _trailingActionOnVideoListItem(item, user),
      onTap: () {
        if (item.status != 'publish_manual' &&
            item.status != 'encoding_failed') {
          _showBottomSheet(item);
        } else if (item.status == 'publish_manual') {
          var screen = VideoPrimaryInfo(item: item, justForEditing: false);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
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
              ? 'Your uploaded videos are in video encoding process\nCome back soon to publish your videos'
              : currentIndex == 1
              ? 'Your videos are ready to post\nTap on a video to edit details & publish'
              : currentIndex == 2
              ? 'Following videos are already posted\nTap on a video to change thumbnail'
              : 'Following videos failed encoding\nTo publish, consider re-uploading';
          return ListTile(
            dense: true,
            title: Text(
              text,
              textAlign: TextAlign.center,
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
    var published = items.where((item) => item.status == 'published').toList();
    var ready = items.where((item) => item.status == 'publish_manual').toList();
    var failed =
        items.where((item) => item.status == 'encoding_failed').toList();
    var process = items
        .where((item) =>
            item.status != 'published' &&
            item.status != 'publish_manual' &&
            item.status != 'encoding_failed')
        .toList();
    return TabBarView(
      controller: _tabController,
      children: [
        SafeArea(
          child: _listViewForItems(process, user),
        ),
        SafeArea(
          child: _listViewForItems(ready, user),
        ),
        SafeArea(
          child: _listViewForItems(published, user),
        ),
        SafeArea(
          child: _listViewForItems(failed, user),
        ),
      ],
    );
  }

  Widget _videoFuture(HiveUserData user) {
    return FutureBuilder(
      future: loadVideos,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return _videosList(snapshot.data as List<VideoDetails>, user);
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
    var user = Provider.of<HiveUserData>(context);
    if (user.username != null && loadVideos == null) {
      setState(() {
        loadVideos = Communicator().loadVideos(user);
      });
    }
    var username = user.username ?? 'Unknown';
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _appBar(username),
        body: Container(
            child: user.username == null
                ? const Center(child: Text('Nothing'))
                : _videoFuture(user)),
      ),
    );
  }
}
