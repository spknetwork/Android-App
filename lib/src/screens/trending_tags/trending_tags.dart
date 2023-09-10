import 'package:acela/src/models/trending_tags/trending_tags_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/trending_tags/trending_tag_videos.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrendingTagsWidget extends StatefulWidget {
  const TrendingTagsWidget({Key? key});

  @override
  State<TrendingTagsWidget> createState() => _TrendingTagsWidgetState();
}

class _TrendingTagsWidgetState extends State<TrendingTagsWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<TrendingTagResponse> getData() async {
    return await GQLCommunicator().getTrendingTags();
  }

  Widget _listTileSubtitle(TrendingTagResponseDataTrendingTag item, int max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Trending Score: ${item.score}"),
        Container(
          height: 5,
        ),
        LinearProgressIndicator(
          value: item.score / max,
        )
      ],
    );
  }

  Widget _listTile(TrendingTagResponseDataTrendingTag item, int max, HiveUserData data) {
    return ListTile(
      leading: const Icon(Icons.tag),
      title: Text(item.tag),
      subtitle: _listTileSubtitle(item, max),
      onTap: () {
        var screen = TrendingTagVideos(tag: item.tag);
        var route = MaterialPageRoute(builder: (c) => screen);
        Navigator.of(context).push(route);
      },
    );
  }

  Widget _list(List<TrendingTagResponseDataTrendingTag> data, HiveUserData appData) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return _listTile(data[index], data[0].score, appData);
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: data.length,
    );
  }

  Widget _body(HiveUserData data) {
    return FutureBuilder<TrendingTagResponse>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return RetryScreen(
                error: snapshot.error?.toString() ?? "Something went wrong",
                onRetry: getData,
              );
            } else if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              return Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: _list((snapshot.data as TrendingTagResponse)
                        .data
                        ?.trendingTags
                        ?.tags ??
                    [], data),
              );
            } else {
              return RetryScreen(
                error: "Something went wrong",
                onRetry: getData,
              );
            }
          } else {
            return const LoadingScreen(
              title: 'Loading Data',
              subtitle: 'Please wait',
            );
          }
        },
        future: getData());
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    super.build(context);
    return _body(appData);
  }
}
