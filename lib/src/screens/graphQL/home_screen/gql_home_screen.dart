import 'dart:developer';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/drawer_screen/drawer_screen.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/widgets/loading_state_widget.dart';
import 'package:acela/src/widgets/new_gql_list_title_video.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

class GQLScreenParams {
  String query;
  String title;
  String value;
  bool shouldShowDrawer;

  GQLScreenParams({
    required this.query,
    required this.title,
    required this.shouldShowDrawer,
    required this.value,
  });

  static String trending = """
{
  trendingFeed(apps: "3speak/0.3.0") {
    items {
      ... on HivePost {
        title
        author
        body
        image
        permlink
        three_video
        lang
        created_at
        app
        app_metadata
        community
      }
    }
  }
}
""";

  static String firstUploads = """
{
  firstUploadsFeeds {
    items {
      ... on HivePost {
        title
        author
        body
        image
        permlink
        three_video
        lang
        created_at
        app
        app_metadata
        community
      }
    }
  }
}
""";

  static String latestFeed = """
{
  latestFeed(apps: "3speak/0.3.0") {
    items {
      ... on HivePost {
        title
        author
        body
        image
        permlink
        three_video
        lang
        created_at
        app
        app_metadata
        community
      }
    }
  }
}
""";

  static String publicFeed = """
{
  publicFeed(apps: "3speak/0.3.0") {
    items {
      ... on HivePost {
        title
        author
        body
        image
        permlink
        three_video
        lang
        created_at
        app
        app_metadata
        community
      }
    }
  }
}
""";

  static String followingFeed(String follower) {
    return """
{
  followingFeed(follower: "$follower") {
    items {
      ... on HivePost {
        title
        author
        body
        image
        permlink
        three_video
        lang
        created_at
        app
        app_metadata
        community
      }
    }
  }
}
""";
  }

}
class GQLHomeScreen extends StatefulWidget {
  const GQLHomeScreen({
    Key? key,
    required this.params,
  }) : super(key: key);
  final GQLScreenParams params;

  factory GQLHomeScreen.trending() {
    return GQLHomeScreen(
      params: GQLScreenParams(
        title: 'Trending Content',
        shouldShowDrawer: true,
        query: GQLScreenParams.trending,
        value: "trendingFeed",
      ),
    );
  }

  factory GQLHomeScreen.firstUploads() {
    return GQLHomeScreen(
      params: GQLScreenParams(
        title: 'First Uploads',
        shouldShowDrawer: true,
        query: GQLScreenParams.firstUploads,
        value: "firstUploadsFeeds",
      ),
    );
  }

  factory GQLHomeScreen.publicFeed() {
    return GQLHomeScreen(
      params: GQLScreenParams(
        title: 'Home',
        shouldShowDrawer: true,
        query: GQLScreenParams.publicFeed,
        value: "publicFeed",
      ),
    );
  }

  factory GQLHomeScreen.newContent() {
    return GQLHomeScreen(
      params: GQLScreenParams(
        title: 'New Content',
        shouldShowDrawer: true,
        query: GQLScreenParams.latestFeed,
        value: "latestFeed",
      ),
    );
  }

  @override
  State<GQLHomeScreen> createState() => _GQLHomeScreenState();
}

class _GQLHomeScreenState extends State<GQLHomeScreen> {
  ListTile _newItem(
    dynamic item,
    bool isAlternate,
    HiveUserData data,
  ) {
    String? imageUrl = item['image']?[0] as String?;
    var durationValue = 0.0;
    try {
      durationValue = item['three_video']?['duration'] as double? ?? 0.0;
    } catch (e) {
      var intValue = item['three_video']?['duration'] as int? ?? 0;
      durationValue = intValue.toDouble();
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      title: NewGQLListTitleVideo(
        isAlternate: isAlternate,
        title: item['title'] ?? '',
        permlink: item['permlink'] ?? '',
        user: item['author'] ?? '',
        placeholder: 'assets/branding/three_speak_logo.png',
        url: imageUrl ?? '',
        community: item['community']?['title'] ?? 'Hive',
        created: item['created_at'] ?? '',
        data: data,
        duration: durationValue.toInt(),
        onUserTap: () {
          var channel =
              UserChannelScreen(owner: item['author'] ?? 'sagarkothari88');
          var route = MaterialPageRoute(builder: (_) => channel);
          Navigator.of(context).push(route);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    var query = widget.params.query;
    final httpLink =
        HttpLink('https://spk-union.us-west.web3telekom.xyz/api/v1/graphql');
    final client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: GraphQLCache(),
        link: httpLink,
      ),
    );
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.params.title),
        ),
        drawer: DrawerScreen(),
        body: Query(
          options: QueryOptions(
            document: gql(query), // this is the query string you just created
            // variables: {
            //   'nRepositories': 50,
            // },
            // pollInterval: const Duration(seconds: 10),
            pollInterval: Duration(days: 1),
          ),
          // Just like in apollo refetch() could be used to manually trigger a refetch
          // while fetchMore() can be used for pagination purpose
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            log('Just polled data');
            if (result.hasException) {
              return Text(result.exception.toString());
            }
            if (result.isLoading) {
              return LoadingStateWidget();
            }
            List? items = result.data?[widget.params.value]?['items'];
            if (items == null) {
              return const Text('No items');
            }
            final opts = FetchMoreOptions(
              variables: {
                'skip': items.length,
              },
              updateQuery: (previousResultData, fetchMoreResultData) {
                final newItems = [
                  ...previousResultData!['firstUploadsFeeds']['items']
                      as List<dynamic>,
                  ...fetchMoreResultData!['firstUploadsFeeds']['items']
                      as List<dynamic>
                ];
                fetchMoreResultData['firstUploadsFeeds']['items'] = newItems;
                return fetchMoreResultData;
              },
            );
            return ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return ListTile(
                    title: const Text('Load More'),
                    onTap: () {
                      fetchMore!(opts);
                    },
                  );
                }
                final item = items[index];
                return _newItem(item, index % 2 == 0, appData);
              },
            );
          },
        ),
      ),
    );
  }
}
