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

class _UserChannelScreenState extends State<UserChannelScreen> {
  List<HomeFeedItem> items = [];

  Future<UserProfileResponse> loadUserProfile(String author) async {
    var client = http.Client();
    var body = UserProfileRequest.forOwner(widget.owner).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      _loadFeed();
      return UserProfileResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  void _loadFeed() {
    get(Uri.parse("${server.domain}/apiv2/feeds/@${widget.owner}"))
        .then((value) {
      if (value.statusCode == 200) {
        List<HomeFeedItem> list = homeFeedItemFromString(value.body);
        setState(() {
          items = list;
        });
      }
    });
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
      //data.result.metadata.profile.coverImage,
      fit: BoxFit.cover,
      imageErrorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
        return Image.asset('assets/branding/three_speak_logo.png');
      },
    );
  }

  Widget _thumbnail(String url, String name) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          CustomCircleAvatar(
              height: 100,
              width: 100,
              url: url), //data.result.metadata.profile.profileImage),
          const SizedBox(
            width: 10,
          ),
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  Widget _bio(String bio) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Expanded(child: Text(bio)),
    );
  }

  Widget _userProfile(UserProfileResponse data) {
    return ListView.separated(
      itemBuilder: (context, index) {
        if (index == 0) {
          return _cover(data.result.metadata.profile.coverImage);
        } else if (index == 1) {
          return _thumbnail(
              data.result.metadata.profile.profileImage, data.result.name);
        } else if (index == 2) {
          return _bio(data.result.metadata.profile.about);
        } else {
          return _listTile(items[index - 3], context, (item) {
            log("tapped on item ${item.permlink}");
            Navigator.of(context).pushNamed(
                VideoDetailsScreen.routeName(item.author, item.permlink));
          }, (owner) {
            log("tapped on user ${owner.author}");
          });
        }
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 0, height: 1, color: Colors.transparent),
      itemCount: items.length + 3,
    );
  }

  Widget _futureBuilder() {
    return FutureBuilder(
      future: loadUserProfile(widget.owner),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Firebase not initialized');
        } else if (snapshot.hasData) {
          var data = snapshot.data! as UserProfileResponse;
          return _userProfile(data);
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.owner),
      ),
      body: _futureBuilder(),
    );
  }
}
