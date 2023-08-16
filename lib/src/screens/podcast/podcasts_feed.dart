import 'package:acela/src/models/podcast/podcast_episodes.dart';
import 'package:acela/src/models/podcast/trending_podcast_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/podcast/podcast_communicator.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/podcast_player.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  CarouselController controller = CarouselController();

  @override
  void initState() {
    super.initState();
    future = PodCastCommunicator().getPodcastEpisodesByFeedId("${widget.item.id ?? 227573}");
  }

  Widget _fullPost(PodcastEpisode item) {
    return PodcastEpisodePlayer(
      episode: item,
      data: widget.appData,
      didFinish: () {
        setState(() {
          controller.nextPage();
        });
      },
    );
  }

  Widget carousel(List<PodcastEpisode> items) {
    return Container(
      child: CarouselSlider(
        carouselController: controller,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          enableInfiniteScroll: true,
          viewportFraction: 1,
          scrollDirection: Axis.vertical,
        ),
        items: items.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return _fullPost(item);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Image.network(
            widget.item.image ?? '',
            width: 40,
            height: 40,
          ),
          title: Text(widget.item.title ?? 'No Title'),
        ),
      ),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return RetryScreen(
                error: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    future = PodCastCommunicator().getPodcastEpisodesByFeedId("${widget.item.id ?? 227573}");
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
                      future = PodCastCommunicator().getPodcastEpisodesByFeedId("${widget.item.id ?? 227573}");
                    });
                  });
            } else {
              return carousel(list);
            }
          } else {
            return LoadingScreen(title: 'Loading', subtitle: 'Please wait..');
          }
        },
      ),
    );
  }
}
