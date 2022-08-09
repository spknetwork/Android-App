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
import 'package:acela/src/utils/communicator.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
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
  var isFabLoading = false;

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
      while (i < list.length) {
        if (mounted) {
          var info = await Communicator()
              .fetchHiveInfo(list[i].author, list[i].permlink);
          setState(() {
            payout["${list[i].author}/${list[i].permlink}"] = info;
            i++;
          });
        } else {
          break;
        }
      }
    } else {
      showError('Status code ${response.statusCode}');
      setState(() {
        isLoading = false;
        items = [];
      });
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

  Widget _fabNewUpload() {
    return FloatingActionButton(
      onPressed: () {
        showAdaptiveActionSheet(
          context: context,
          title: const Text('Select record type'),
          androidBorderRadius: 30,
          actions: <BottomSheetAction>[
            BottomSheetAction(
              title: const Text('Camera'),
              onPressed: (c) {
                var screen = const NewVideoUploadScreen(camera: true);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).pop();
                Navigator.of(context).push(route);
              },
            ),
            BottomSheetAction(
                title: const Text('Photo Gallery'),
                onPressed: (c) {
                  var screen = const NewVideoUploadScreen(camera: false);
                  var route = MaterialPageRoute(builder: (c) => screen);
                  Navigator.of(context).pop();
                  Navigator.of(context).push(route);
                }),
          ],
          cancelAction: CancelAction(title: const Text('Cancel')),
        );
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
        floatingActionButton:
            user == null ? null : _fabNewUpload() //_fab(user),
        );
  }
}
