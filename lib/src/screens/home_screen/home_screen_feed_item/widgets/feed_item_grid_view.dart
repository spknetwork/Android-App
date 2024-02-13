import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/home_screen_feed_item/widgets/new_feed_list_item.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:flutter/material.dart';

class FeedItemGridView extends StatelessWidget {
  const FeedItemGridView({
    Key? key,
    required this.screenWidth,
    required this.items,
    required this.appData,
     this.scrollController,
     this.nextPageLoader,
  }) : super(key: key);

  final double screenWidth;
  final List<GQLFeedItem> items;
  final HiveUserData appData;
  final ScrollController? scrollController;
  final Widget? nextPageLoader;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          FeedItemGridWidget(items: items,appData: appData),
          SliverToBoxAdapter(
            child: nextPageLoader,
          ),
        ],
      ),
    );
  }


}

class FeedItemGridWidget extends StatelessWidget {
  const FeedItemGridWidget({
    Key? key,
    required this.items,
    required this.appData,
  }) : super(key: key);

  final List<GQLFeedItem> items;
  final HiveUserData appData;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width ;
    return SliverGrid.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(width),
        childAspectRatio:
            MediaQuery.of(context).orientation == Orientation.landscape
                ? 1.25
                : 1.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        var item = items[index];
        return NewFeedListItem(
          isGridView: true,
          key: ValueKey(index),
          showVideo: false,
          thumbUrl: item.spkvideo?.thumbnailUrl ?? '',
          author: item.author?.username ?? '',
          title: item.title ?? '',
          createdAt: item.createdAt ?? DateTime.now(),
          duration: item.spkvideo?.duration ?? 0.0,
          comments: item.stats?.numComments ?? 0,
          hiveRewards: item.stats?.totalHiveReward,
          votes: item.stats?.numVotes,
          views: 0,
          permlink: item.permlink ?? '',
          onTap: () {},
          onUserTap: () {},
          item: item,
          appData: appData,
        );
      },
    );
  }

    int getCrossAxisCount(double width) {
    if (width > 1300) {
      return 4;
    } else if (width > 974 && width < 1300) {
      return 3;
    } else if (width > 650 && width < 974) {
      return 2;
    } else {
      return 2;
    }
  }
}
