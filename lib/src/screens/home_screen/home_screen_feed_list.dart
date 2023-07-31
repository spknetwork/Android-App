import 'dart:developer';

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

class _HomeScreenFeedListState extends State<HomeScreenFeedList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<GQLFeedItem> items = [];
  var firstPageLoaded = false;
  var isLoading = false;
  var hasFailed = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadFeed(false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && items.length % 50 == 0) {
        loadFeed(false);
      }
    });
  }

  Future<List<GQLFeedItem>> loadWith(bool firstPage) {
    try {
      switch (widget.feedType) {
        case HomeScreenFeedType.trendingFeed:
          return GQLCommunicator()
              .getTrendingFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.newUploads:
          return GQLCommunicator()
              .getNewUploadsFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.firstUploads:
          return GQLCommunicator()
              .getFirstUploadsFeed(false, firstPage ? 0 : items.length);
        case HomeScreenFeedType.userFeed:
          return GQLCommunicator().getMyFeed(
              widget.appData.username ?? 'sagarkothari88',
              false,
              firstPage ? 0 : items.length);
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
        firstPageLoaded = false;
      });
      var newItems = await loadWith(true);
      setState(() {
        items = newItems;
        isLoading = false;
        firstPageLoaded = true;
      });
    } else {
      setState(() {
        isLoading = true;
        if (reset) {
          firstPageLoaded = false;
        }
      });
      var newItems = await loadWith(reset);
      setState(() {
        items = items + newItems;
        isLoading = false;
        firstPageLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading && !firstPageLoaded) {
      return LoadingScreen(title: 'Loading', subtitle: 'Please wait');
    } else if (hasFailed) {
      return RetryScreen(
        onRetry: () async {
          loadFeed(true);
        },
        error: 'Something went wrong. Try again.',
      );
    } else {
      if (items.isEmpty) {
        return Center(
          child: Column(
            children: [
              Text(
                  'We did not find anything to show.\nTap on Reload button to try again.'),
              ElevatedButton(
                onPressed: () {
                  loadFeed(true);
                },
                child: Text('Reload'),
              )
            ],
          ),
        );
      } else {
        return RefreshIndicator(
          onRefresh: () async {
            loadFeed(true);
          },
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (c, i) {
              if (items.length == i) {
                return ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Loading next page'),
                  subtitle: Text('Please wait...'),
                );
              }
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
            itemCount: items.length % 50 == 0 ? items.length + 1 : items.length,
          ),
        );
      }
    }
  }
}
