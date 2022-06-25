import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_profile/request/user_followers_request.dart';
import 'package:acela/src/models/user_profile/response/followers_and_following.dart';
import 'package:acela/src/screens/user_channel_screen/follower_list_tile.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserChannelFollowingWidget extends StatefulWidget {
  const UserChannelFollowingWidget(
      {Key? key, required this.owner, required this.isFollowers})
      : super(key: key);
  final String owner;
  final bool isFollowers;

  @override
  State<UserChannelFollowingWidget> createState() =>
      _UserChannelFollowingWidgetState();
}

class _UserChannelFollowingWidgetState extends State<UserChannelFollowingWidget>
    with AutomaticKeepAliveClientMixin<UserChannelFollowingWidget> {
  @override
  bool get wantKeepAlive => true;

  Future<Followers> _loadFollowers(String author) async {
    var client = http.Client();
    var body = widget.isFollowers
        ? UserFollowerRequest.followers(widget.owner).toJsonString()
        : UserFollowerRequest.following(widget.owner).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      return Followers.fromJsonString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Widget _listTile(FollowerItem item) {
    return FollowerListTile(
      name: widget.isFollowers ? item.follower : item.following,
    );
  }

  Widget _futureFollowers() {
    return FutureBuilder(
      future: _loadFollowers(widget.owner),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading user followers');
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data! as Followers;
          if (data.result.isEmpty) {
            return Center(
              child: Text(
                  'No ${widget.isFollowers ? 'Followers' : 'Followings'} found.'),
            );
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              return _listTile(data.result[index]);
            },
            separatorBuilder: (context, index) => const Divider(
                thickness: 0, height: 1, color: Colors.transparent),
            itemCount: data.result.length,
          );
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _futureFollowers();
  }
}
