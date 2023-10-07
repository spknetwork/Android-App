import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_feed_item.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

class PodcastFeedsBody extends StatefulWidget {
  const PodcastFeedsBody(
      {Key? key, required this.future, required this.appData})
      : super(key: key);

  final Future future;
  final HiveUserData appData;

  @override
  State<PodcastFeedsBody> createState() => _PodcastFeedsBodyState();
}

class _PodcastFeedsBodyState extends State<PodcastFeedsBody> {
  late Future future;
  @override
  void initState() {
    future = widget.future;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PodcastFeedsBody oldWidget) {
    future = widget.future;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return RetryScreen(
            error: snapshot.error.toString(),
            onRetry: () {
              setState(() {
                future = widget.future;
              });
            },
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data as TrendingPodCastResponse;
          var list = data.feeds ?? [];
          if (list.isEmpty) {
            return RetryScreen(
              error: 'No data found.',
              onRetry: () {
                setState(() {
                  future = widget.future;
                });
              },
            );
          } else {
            return getList(list);
          }
        } else {
          return LoadingScreen(title: 'Loading', subtitle: 'Please wait..');
        }
      },
    );
  }

  Widget getList(List<PodCastFeedItem> items) {
    return ListView.separated(
      itemBuilder: (c, i) {
        return PodcastFeedItemWidget(
          appData: widget.appData,
          item: items[i],
        );
      },
      separatorBuilder: (c, i) => const Divider(height: 0),
      itemCount: items.length,
    );
  }
}
