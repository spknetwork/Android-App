import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
        image
        body
        author
        title
        three_video
        permlink
        author_profile {
          id
          username
          name
        }
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
              variables: {'skip': items.length},
              updateQuery: (previousResultData, fetchMoreResultData) {
                // this is where you combine your previous data and response
                // in this case, we want to display previous repos plus next repos
                // so, we combine data in both into a single list of repos
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
                return ListTile(
                  title: Text('$index - ${item['title'] ?? ''}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
