import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_profile/request/user_profile_request.dart';
import 'package:acela/src/models/user_profile/response/user_profile.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' show get;
import 'package:timeago/timeago.dart' as timeago;

class UserChannelScreen extends StatefulWidget {
  const UserChannelScreen({Key? key, required this.owner}) : super(key: key);
  final String owner;

  @override
  _UserChannelScreenState createState() => _UserChannelScreenState();
}

class _UserChannelScreenState extends State<UserChannelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Tab> tabs = [
    Tab(text: 'About'),
    Tab(text: 'Videos'),
    Tab(text: 'Followers'),
    Tab(text: 'Following'),
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<UserProfileResponse> loadUserProfile(String author) async {
    var client = http.Client();
    var body = UserProfileRequest.forOwner(widget.owner).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      return UserProfileResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }
  
  Future<List<HomeFeedItem>> loadFeed(String author) async {
    var response = await get(Uri.parse("${server.domain}/apiv2/feeds/@${widget.owner}"));
    if (response.statusCode == 200) {
      List<HomeFeedItem> list = homeFeedItemFromString(response.body);
      return list;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Widget _tileTitle(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onUserTap) {
    String timeInString =
        item.createdAt != null ? "📆 ${timeago.format(item.createdAt!)}" : "";
    String owner = "👤 ${item.author}";
    String duration = "🕚 ${Utilities.formatTime(item.duration.toInt())}";
    String views = "▶ ${item.views}";
    return ListTileVideo(
      placeholder: 'assets/branding/three_speak_logo.png',
      url: item.images.thumbnail,
      userThumbUrl: server.userOwnerThumb(item.author),
      title: item.title,
      subtitle: "$timeInString $owner $duration $views",
      onUserTap: () {
        onUserTap(item);
      },
    );
  }

  Widget _listTile(HomeFeedItem item, BuildContext context,
      Function(HomeFeedItem) onTap, Function(HomeFeedItem) onUserTap) {
    return ListTile(
      title: _tileTitle(item, context, onUserTap),
      onTap: () {
        onTap(item);
      },
    );
  }

  Widget _cover(String url) {
    return FadeInImage.assetNetwork(
      height: 150,
      placeholder: 'assets/branding/three_speak_logo.png',
      image: url,
      fit: BoxFit.cover,
      imageErrorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Image.asset('assets/branding/three_speak_logo.png');
      },
    );
  }

  Widget _futureVideos() {
    return FutureBuilder(
      future: loadFeed(widget.owner),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error loading user profile');
          } else if (snapshot.hasData) {
            var data = snapshot.data! as List<HomeFeedItem>;
            return ListView.separated(
              itemBuilder: (context, index) {
                return _listTile(data[index], context, (item) {
                  log("tapped on item ${item.permlink}");
                  Navigator.of(context).pushNamed(
                      VideoDetailsScreen.routeName(item.author, item.permlink));
                }, (owner) {
                  log("tapped on user ${owner.author}");
                });
              },
              separatorBuilder: (context, index) =>
              const Divider(thickness: 0, height: 1, color: Colors.transparent),
              itemCount: data.length,
            );
          } else {
            return const LoadingScreen();
          }
    });
  }

  Widget _futureUserProfile() {
    return FutureBuilder(
      future: loadUserProfile(widget.owner),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading user profile');
        } else if (snapshot.hasData) {
          var data = snapshot.data! as UserProfileResponse;
          return Column(
            children: [
              _cover(data.result.metadata.profile.coverImage),
              const SizedBox(height: 10),
              CustomCircleAvatar(height: 100, width: 100, url: data.result.metadata.profile.profileImage),
              Text(widget.owner, style: Theme.of(context).textTheme.headline5),
              const SizedBox(height: 10),
              data.result.metadata.profile.about.isEmpty ? const Text('No Bio') : Text(data.result.metadata.profile.about),
              const SizedBox(height: 10),
              Text('Created at: ${Utilities.parseAndFormatDateTime(data.result.created)}'),
              const SizedBox(height: 10),
              Text('Last seen at: ${Utilities.parseAndFormatDateTime(data.result.active)}'),
              const SizedBox(height: 10),
              Text('Total Hive Posts: ${data.result.postCount}'),
              const SizedBox(height: 10),
              Text('Reputation: ${data.result.reputation}'),
              const SizedBox(height: 10),
              Text('Website: ${data.result.metadata.profile.website.isEmpty ? 'None' : data.result.metadata.profile.website}'),
              const SizedBox(height: 10),
              Text('Location: ${data.result.metadata.profile.location.isEmpty ? 'None' : data.result.metadata.profile.location}'),
              const Spacer(),
            ],
          );
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  Widget _followers() {

  }

  Widget _following() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.owner),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _futureUserProfile(),
          _futureVideos(),
          const Text('Followers'),
          const Text('Following'),
        ],
      ),
    );
  }
}
