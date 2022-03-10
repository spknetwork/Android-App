import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoDetailsInfoWidget extends StatelessWidget {
  const VideoDetailsInfoWidget({Key? key, required this.details}) : super(key: key);
  final VideoDetails details;

  Widget header(BuildContext context) {
    String string =
        "📆 ${timeago.format(DateTime.parse(details.created))} · ▶ ${details.views} views · 👥 ${details.community}";
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details.title,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 3),
            Text(string, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget descriptionMarkDown(String markDown) {
    return Markdown(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      data: Utilities.removeAllHtmlTags(markDown),
      onTapLink: (text, url, title) {
        launch(url!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(details.owner),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 70),
              child: descriptionMarkDown(details.description),
            ),
            header(context),
          ],
        ),
      ),
    );
  }
}
