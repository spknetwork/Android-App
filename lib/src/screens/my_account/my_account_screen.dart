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

class _MyAccountScreenState extends State<MyAccountScreen> {
  Future<List<VideoDetails>>? loadVideos;

  void logout() async {
    // Create storage
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'postingKey');
    await storage.delete(key: 'cookie');
    String resolution = await storage.read(key: 'resolution') ?? '480p';
    server.updateHiveUserData(
      HiveUserData(
        username: null,
        postingKey: null,
        cookie: null,
        resolution: resolution,
      ),
    );
    Navigator.of(context).pop();
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  AppBar _appBar(String username) {
    return AppBar(
      title: Row(
        children: [
          CustomCircleAvatar(
            height: 36,
            width: 36,
            url: 'https://images.hive.blog/u/$username/avatar',
          ),
          const SizedBox(width: 5),
          Text(username),
        ],
      ),
      bottom: const TabBar(
        tabs: [
          Tab(icon: Icon(Icons.hourglass_top)),
          Tab(icon: Icon(Icons.rocket_launch)),
          Tab(icon: Icon(Icons.check)),
          Tab(icon: Icon(Icons.cancel_rounded)),
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
        ? const Icon(Icons.check, color: Colors.green)
        : item.status == "encoding_failed"
            ? const Icon(Icons.cancel_outlined, color: Colors.red)
            : item.status == 'publish_manual'
                ? IconButton(
                    onPressed: () {
                      var screen = VideoPrimaryInfo(item: item);
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
                    color: Colors.blue,
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
          var screen = VideoPrimaryInfo(item: item);
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
        return _videoListItem(items[index], user);
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: items.length,
    );
  }

  Widget _videosList(List<VideoDetails> items, HiveUserData user) {
    var published = items.where((item) => item.status == 'published').toList();
    var ready = items.where((item) => item.status == 'publish_manual').toList();
    var failed =
        items.where((item) => item.status == 'encoding_failed').toList();
    var process = items
        .where((item) =>
            item.status != 'published' && item.status != 'publish_manual')
        .toList();
    return TabBarView(
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
