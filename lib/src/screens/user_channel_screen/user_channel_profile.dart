import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_profile/request/user_profile_request.dart';
import 'package:acela/src/models/user_profile/response/user_profile.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UserChannelProfileWidget extends StatefulWidget {
  const UserChannelProfileWidget({Key? key, required this.owner})
      : super(key: key);
  final String owner;

  @override
  State<UserChannelProfileWidget> createState() =>
      _UserChannelProfileWidgetState();
}

class _UserChannelProfileWidgetState extends State<UserChannelProfileWidget>
    with AutomaticKeepAliveClientMixin<UserChannelProfileWidget> {
  @override
  bool get wantKeepAlive => true;

  Future<UserProfileResponse> _loadUserProfile() async {
    var client = http.Client();
    var body = UserProfileRequest.forOwner(widget.owner).toJsonString();
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      return UserProfileResponse.fromString(response.body);
    } else {
      throw "Status code is ${response.statusCode}";
    }
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

  Widget _descriptionMarkDown(String markDown) {
    return Markdown(
      padding: const EdgeInsets.all(3),
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  String _generateMarkDown(UserProfileResponse data) {
    return "![cover image](${data.result.metadata.profile.coverImage})\n## Bio:\n${data.result.metadata.profile.about}\n\n\n## Created At:\n${Utilities.parseAndFormatDateTime(data.result.created)}\n\n## Last Seen At:\n${Utilities.parseAndFormatDateTime(data.result.active)}\n\n## Total Hive Posts:\n${data.result.postCount}\n\n## Hive Reputation:\n${data.result.reputation}\n\n## Location:\n${data.result.metadata.profile.location.isEmpty ? 'None' : data.result.metadata.profile.location}\n\n## Website:\n${data.result.metadata.profile.website.isEmpty ? 'None' : data.result.metadata.profile.website}";
  }

  Widget _futureUserProfile() {
    return FutureBuilder(
      future: _loadUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading user profile');
        } else if (snapshot.hasData) {
          var data = snapshot.data! as UserProfileResponse;
          return _descriptionMarkDown(_generateMarkDown(data));
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _futureUserProfile();
  }
}
