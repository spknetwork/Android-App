import 'package:acela/src/models/graphql/gql_communicator.dart';
import 'package:acela/src/models/graphql/models/trending_feed_response.dart';
import 'package:loading_more_list/loading_more_list.dart';

class HomeScreenFeedsRepository extends LoadingMoreBase<GQLFeedItem> {
  List<GQLFeedItem> items = [];
  bool forceRefresh = false;


  @override
  bool get hasMore => (items.length % 100 == 0) || forceRefresh;

  @override
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    items = [];
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    List<GQLFeedItem> newItems = [];
    if (items.isEmpty) {
      newItems = await GQLCommunicator().getTrendingFeed(false, 0);
    } else {
      newItems = await GQLCommunicator().getTrendingFeed(false, items.length);
    }
    newItems.forEach((element) {
      this.add(element);
    });
    return true;
  }
}