import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_upload/platform_video_info.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen_widgets.dart';
import 'package:acela/src/screens/search/search_screen.dart';
import 'package:acela/src/screens/upload/upload_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  static const platform = MethodChannel('com.example.acela/encoder');

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

  Widget _fab(HiveUserData user) {
    if (isFabLoading) {
      return FloatingActionButton(
          onPressed: () {}, child: const CircularProgressIndicator());
    }
    return FloatingActionButton(
      onPressed: () async {
        try {
          setState(() {
            isFabLoading = true;
          });
          FilePickerResult? fileResult =
              await FilePicker.platform.pickFiles(type: FileType.video);

          if (fileResult != null && fileResult.files.single.path != null) {
            PlatformFile file = fileResult.files.single;
            print(file.name);
            print(file.bytes);
            print(file.size);
            print(file.extension);
            print(file.path);
            MediaInformationSession session =
                await FFprobeKit.getMediaInformation(file.path!);
            var info = session.getMediaInformation();
            var duration =
                (double.tryParse(info?.getDuration() ?? "0.0") ?? 0.0).toInt();
            log('Video duration is $duration');
            final xfile = XFile(fileResult.files.single.path!);
            var fileInfoInString = json.encode(PlatformVideoInfo(
                    duration: int.tryParse(info?.getDuration() ?? "0") ?? 0,
                    oFilename: xfile.name,
                    path: xfile.path,
                    size: int.tryParse(info?.getSize() ?? "0") ?? 0)
                .toJson());
            var cookie = await Communicator().getValidCookie(user);
            log('Cookie is $cookie');
            final fcmToken = await FirebaseMessaging.instance.getToken();
            log('FCM Token is $fcmToken');
            await Communicator().addToken(user, fcmToken ?? "");
            var response = await Communicator()
                .prepareVideo(user, fileInfoInString, cookie);
            log('Response file name is ${response.filename}');
            setState(() {
              isLoading = false;
            });
            var screen = UploadScreen(videoId: response.video.id, xFile: xfile);
            var route = MaterialPageRoute(builder: (c) => screen);
            Navigator.of(context).push(route);
          } else {
            throw 'User cancelled the video picker';
          }
        } catch (e) {
          showError(e.toString());
          setState(() {
            isFabLoading = false;
          });
        }
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
      floatingActionButton: user == null ? null : _fab(user),
    );
  }
}
