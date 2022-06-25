import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_profile/request/user_profile_request.dart';
import 'package:acela/src/models/user_profile/response/user_profile.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FollowerListTile extends StatefulWidget {
  const FollowerListTile({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<FollowerListTile> createState() => _FollowerListTileState();
}

class _FollowerListTileState extends State<FollowerListTile>
    with AutomaticKeepAliveClientMixin<FollowerListTile> {
  @override
  bool get wantKeepAlive => true;

  Future<UserProfileResponse> _loadUserProfile() async {
    var client = http.Client();
    var body = UserProfileRequest.forOwner(widget.name).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      return UserProfileResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Widget _futureUserProfile() {
    return FutureBuilder(
      future: _loadUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ListTile(title: Text(widget.name));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data! as UserProfileResponse;
          return ListTile(
            leading: SizedBox(
              height: 40,
              width: 40,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/branding/three_speak_logo.png',
                image: data.result.metadata.profile.profileImage,
                fit: BoxFit.cover,
                placeholderErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset('assets/branding/three_speak_logo.png');
                },
                imageErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset('assets/branding/three_speak_logo.png');
                },
              ),
            ),
            title: Text(widget.name),
            subtitle: Text('Reputation: ${data.result.reputation}'),
          );
        } else {
          return ListTile(title: Text(widget.name));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // return _futureUserProfile();
    return ListTile(
      leading: CustomCircleAvatar(
        height: 40,
        width: 40,
        url: server.userOwnerThumb(widget.name),
      ),
      title: Text(widget.name),
      onTap: () {
        log('User tapped on hive user list item ${widget.name}');
      },
    );
  }
}
