import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/widgets/audio_player/new_pod_cast_epidose_player.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/screens/podcast/widgets/podcast_player.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

class PodcastFeedScreen extends StatefulWidget {
  const PodcastFeedScreen({
    Key? key,
    required this.appData,
    required this.item,
  });

  final HiveUserData appData;
  final PodCastFeedItem item;

  @override
  State<PodcastFeedScreen> createState() => _PodcastFeedScreenState();
}

class _PodcastFeedScreenState extends State<PodcastFeedScreen> {
  late Future<PodcastEpisodesByFeedResponse> future;

  @override
  void initState() {
    super.initState();
    future = PodCastCommunicator()
        .getPodcastEpisodesByFeedId("${widget.item.id ?? 227573}");
  }

  Widget _fullPost(List<PodcastEpisode> items) {
    return NewPodcastEpidosePlayer();
    // return PodcastEpisodePlayer(
    //   podcastEpisodes: items,
    //   data: widget.appData,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Image.network(
            widget.item.networkImage ?? '',
            width: 40,
            height: 40,
          ),
          title: Text(widget.item.title ?? 'No Title'),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return RetryScreen(
                  error: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      future = PodCastCommunicator().getPodcastEpisodesByFeedId(
                          "${widget.item.id ?? 227573}");
                    });
                  });
            } else if (snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data as PodcastEpisodesByFeedResponse;
              var list = data.items ?? [];
              if (list.isEmpty) {
                return RetryScreen(
                    error: 'No data found.',
                    onRetry: () {
                      setState(() {
                        future = PodCastCommunicator()
                            .getPodcastEpisodesByFeedId(
                                "${widget.item.id ?? 227573}");
                      });
                    });
              } else {
                return _fullPost(list);
              }
            } else {
              return LoadingScreen(title: 'Loading', subtitle: 'Please wait..');
            }
          },
        ),
      ),
    );
  }
}
