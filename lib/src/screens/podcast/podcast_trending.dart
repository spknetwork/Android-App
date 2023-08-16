import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

class PodCastTrendingScreen extends StatefulWidget {
  const PodCastTrendingScreen({Key? key,
    required this.appData,
  });

  final HiveUserData appData;

  @override
  State<PodCastTrendingScreen> createState() => _PodCastTrendingScreenState();
}

class _PodCastTrendingScreenState extends State<PodCastTrendingScreen> {
  late Future<TrendingPodCastResponse> future;

  @override
  void initState() {
    super.initState();
    future = PodCastCommunicator().getTrendingPodcasts();
  }

  Widget getList(List<PodCastFeedItem> items) {
    return ListView.separated(
      itemBuilder: (c, i) {
        return ListTile(
          title: Text(items[i].title ?? 'No title'),
        );
      },
      separatorBuilder: (c, i) => const Divider(),
      itemCount: items.length,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Image.asset('assets/pod-cast-logo-round.png', width: 40, height: 40,),
          title: Text('Podcasts'),
        ),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return RetryScreen(error: snapshot.error.toString(), onRetry: () {
              setState(() {
                future = PodCastCommunicator().getTrendingPodcasts();
              });
            });
          } else if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data as TrendingPodCastResponse;
            var list = data.feeds;
            if (list == null || list.isEmpty) {
              return RetryScreen(error: 'No data found.', onRetry: () {
                setState(() {
                  future = PodCastCommunicator().getTrendingPodcasts();
                });
              });
            } else {
              return getList(list);
            }
          } else {
            return LoadingScreen(title: 'Loading', subtitle: 'Please wait..');
          }
        },
      ),
    );
  }
}
