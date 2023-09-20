import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PodcastInfoDescroption extends StatelessWidget {
  const PodcastInfoDescroption({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String? title;
  final String? description;

  Widget descriptionMarkDown(String markDown) {
    return Markdown(
      padding: const EdgeInsets.all(10),
      data: Utilities.removeAllHtmlTags(markDown),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? ""),
      ),
      body: SafeArea(
        child: descriptionMarkDown(
          description ?? "No content",
        ),
      ),
    );
  }
}
