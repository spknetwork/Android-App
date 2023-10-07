import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_feeds_body.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:flutter/material.dart';

class PodcastCategoryView extends StatelessWidget {
  const PodcastCategoryView(
      {Key? key,
      required this.categoryId,
      required this.categoryName,
      required this.appData})
      : super(key: key);

  final int categoryId;
  final String categoryName;
  final HiveUserData appData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ListTile(
        minLeadingWidth: 0,
        title: Text(categoryName),subtitle: Text("Podcasts under $categoryName category"),)),
      body: PodcastFeedsBody(
          future: PodCastCommunicator().getFeedsByCategory(categoryId),
          appData: appData),
    );
  }
}
