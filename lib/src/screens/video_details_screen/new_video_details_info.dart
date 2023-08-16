import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class NewVideoDetailsInfo extends StatelessWidget {
  const NewVideoDetailsInfo({
    Key? key,
    required this.appData,
    required this.item,
  }) : super(key: key);
  final GQLFeedItem item;
  final HiveUserData appData;

  Widget descriptionMarkDown(String markDown) {
    return Markdown(
      padding: const EdgeInsets.all(10),
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launchUrl(Uri.parse(url ?? 'https://google.com'));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title ?? ""),
      ),
      body: SafeArea(
        child: descriptionMarkDown(
          item.spkvideo?.body ?? item.body ?? "No content",
        ),
      ),
    );
  }
}
