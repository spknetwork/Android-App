import 'dart:async';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/upload/new_video_upload_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.path,
    required this.showDrawer,
    required this.title,
  }) : super(key: key);
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
  Future<List<HomeFeedItem>>? _future;

  @override
  void initState() {
    super.initState();
    if (_future == null) {
      updateFeed();
    }
  }

  Future<List<HomeFeedItem>> _loadFeed() async {
    var response = await get(Uri.parse(widget.path));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw 'Status code ${response.statusCode}';
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

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _screen(HiveUserData appData) {
    return FutureBuilder<List<HomeFeedItem>>(
      builder: (c, s) {
        if (s.connectionState == ConnectionState.done) {
          if (s.hasError) {
            return RetryScreen(
              error: s.error?.toString() ?? "Something went wrong",
              onRetry: () {
                _future = null;
              },
            );
          } else if (s.hasData) {
            var list = s.data as List<HomeFeedItem>;
            return widgets.list(list, (item) {
              onTap(item);
            }, (item) {
              onUserTap(item);
            }, {});
          } else {
            return RetryScreen(
              error: "Something went wrong",
              onRetry: () {
                _future = null;
              },
            );
          }
        } else {
          return const LoadingScreen(
            title: 'Loading Data',
            subtitle: 'Please wait',
          );
        }
      },
      future: _future,
    );
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
              isReel: isReel,
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
                isReel: isReel,
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
    showAdaptiveActionSheet(
      context: context,
      title: const Text('What do you want to upload?'),
      androidBorderRadius: 30,
      actions: <BottomSheetAction>[
        BottomSheetAction(
          title: const Text('3Speak Short'),
          leading: const Icon(Icons.camera_outlined),
          onPressed: (c) {
            Navigator.of(context).pop();
            showBottomSheetForVideoOptions(true, data);
          },
        ),
        BottomSheetAction(
            title: const Text('3Speak Video'),
            leading: const Icon(Icons.video_collection),
            onPressed: (c) {
              Navigator.of(context).pop();
              showBottomSheetForVideoOptions(false, data);
            }),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  Widget _fabNewUpload(HiveUserData data) {
    return FloatingActionButton.extended(
      onPressed: () {
        showBottomSheetForRecordingTypes(data);
      },
      label: const Text('Upload Video'),
      icon: const Icon(Icons.upload),
    );
  }

  void updateFeed() {
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      timer.cancel();
      setState(() {
        _future = _loadFeed();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              var route = MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              );
              Navigator.of(context).push(route);
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: _screen(appData),
      drawer: widget.showDrawer ? const DrawerScreen() : null,
      floatingActionButton: appData.username == null ? null : _fabNewUpload(appData),
    );
  }
}
