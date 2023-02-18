import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/widgets/list_tile_video.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class GQLHomeScreen extends StatefulWidget {
  const GQLHomeScreen({Key? key}) : super(key: key);

  @override
  State<GQLHomeScreen> createState() => _GQLHomeScreenState();
}

class _GQLHomeScreenState extends State<GQLHomeScreen> {
  @override
  Widget build(BuildContext context) {
    var query = """
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
      }
    }
  }
}
    """;
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
          title: Text('New Home Screen'),
        ),
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
              return const Text('Loading');
            }
            List? items = result.data?['firstUploadsFeeds']?['items'];
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
                String? imageUrl = item['image']?[0] as String;
                var created = DateTime.tryParse(item['created_at'] ?? '');
                String timeInString =
                    created != null ? "📆 ${timeago.format(created)}" : "";
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 0,
                  title: ListTileVideo(
                    placeholder: 'assets/branding/three_speak_logo.png',
                    url: imageUrl,
                    title: item['title'] ?? '',
                    subtitle: "$timeInString ",
                    isIpfs: false,
                    permlink: item['permlink'] ?? '',
                    shouldResize: false,
                    userThumbUrl: server.userOwnerThumb(item['author'] ?? ''),
                    user: item['author'] ?? '',
                    onUserTap: () {
                      var channel = UserChannelScreen(
                          owner: item['author'] ?? 'sagarkothari88');
                      var route = MaterialPageRoute(builder: (_) => channel);
                      Navigator.of(context).push(route);
                    },
                  ),
                  onTap: () {
                    var vm = VideoDetailsViewModel(
                        author: item['author'] ?? 'sagarkothari88',
                        permlink: item['permlink'] ??
                            '3speak-development-updates-sagarkothari88');
                    var details = VideoDetailsScreen(vm: vm);
                    var route = MaterialPageRoute(builder: (_) => details);
                    Navigator.of(context).push(route);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
