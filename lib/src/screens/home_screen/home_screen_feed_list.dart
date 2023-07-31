import 'package:acela/src/models/graphql/gql_communicator.dart';
import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/new_feed_list_item.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';

enum HomeScreenFeedType { userFeed, trendingFeed, newUploads, firstUploads }

class HomeScreenFeedList extends StatefulWidget {
  const HomeScreenFeedList({
    Key? key,
    required this.appData,
    required this.feedType,
  });

  final HiveUserData appData;
  final HomeScreenFeedType feedType;

  @override
  State<HomeScreenFeedList> createState() => _HomeScreenFeedListState();
}

class _HomeScreenFeedListState extends State<HomeScreenFeedList> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<GQLFeedItem> items = [];
  var firstPageLoaded = false;
  var isLoading = false;
  var hasFailed = false;

  @override
  void initState() {
    super.initState();
    loadFeed(false);
  }

  Future<List<GQLFeedItem>> loadWith(bool firstPage) async {
    try {
      switch (widget.feedType) {
        case HomeScreenFeedType.trendingFeed:
          return await GQLCommunicator()
              .getTrendingFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.newUploads:
          return await GQLCommunicator()
              .getNewUploadsFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.firstUploads:
          return await GQLCommunicator()
              .getFirstUploadsFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.userFeed:
          return await GQLCommunicator().getMyFeed(
              widget.appData.username ?? 'sagarkothari88',
              false,
              firstPage ? 0 : items.length);
        default:
          return await GQLCommunicator()
              .getTrendingFeed(false, firstPage ? 0 : items.length);
      }
    } catch (e) {
      hasFailed = true;
      throw e;
    }
  }

  void loadFeed(bool reset) async {
    if (isLoading) return;
    if (!firstPageLoaded) {
      setState(() {
        isLoading = true;
      });
      var newItems = await loadWith(true);
      setState(() {
        items = newItems;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = true;
      });
      var newItems = await loadWith(reset);
      setState(() {
        items = newItems;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingScreen(title: 'Loading', subtitle: 'Please wait');
    } else if (hasFailed) {
      return RetryScreen(
        onRetry: () {
          loadWith(true);
        },
        error: 'Something went wrong. Try again.',
      );
    } else {
      if (items.isEmpty) {
        return Center(
          child: Column(
            children: [
              Text('We did not find anything to show.\nTap on Reload button to try again.'),
              ElevatedButton(
                onPressed: () {
                  loadWith(true);
                },
                child: Text('Reload'),
              )
            ],
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            loadWith(true);
          },
          child: ListView.separated(
            itemBuilder: (c, i) {
              var item = items[i];
              return NewFeedListItem(
                thumbUrl: item.spkvideo?.thumbnailUrl ?? '',
                author: item.author?.username ?? '',
                title: item.title ?? '',
                createdAt: item.createdAt ?? DateTime.now(),
                duration: item.spkvideo?.duration ?? 0.0,
                comments: item.stats?.numComments,
                hiveRewards: item.stats?.totalHiveReward,
                votes: item.stats?.numVotes,
                views: 0,
                permlink: item.permlink ?? '',
                onTap: () {},
                onUserTap: () {},
              );
            },
            separatorBuilder: (c, i) => const Divider(),
            itemCount: items.length,
          ),
        );
      }
    }
  }
}
