import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/communities_models/response/communities_response_models.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/communities_screen/community_details/community_details_screen.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({
    Key? key,
    required this.didSelectCommunity,
  }) : super(key: key);
  final Function(String, String)? didSelectCommunity;

  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  Future<List<CommunityItem>>? _future;

  TextEditingController searchController = TextEditingController();
  Widget _listTile(CommunityItem item) {
    var formatter = NumberFormat();
    var extra =
        "${item.about}\n\n${formatter.format(item.subscribers)} subscribers\n\$${formatter.format(item.sumPending)} pending rewards\n${formatter.format(item.numAuthors)} active posters";
    return ListTile(
      leading: CustomCircleAvatar(
        width: 60,
        height: 60,
        url: server.communityIcon(item.name),
      ),
      title: Text(item.title),
      subtitle: Text(extra),
      onTap: () {
        if (widget.didSelectCommunity != null) {
          widget.didSelectCommunity!(item.title, item.name);
          Navigator.of(context).pop();
        } else {
          var screen =
              CommunityDetailScreen(name: item.name, title: item.title);
          var route = MaterialPageRoute(builder: (c) => screen);
          Navigator.of(context).push(route);
        }
      },
    );
  }

  Widget _list(List<CommunityItem> data) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 80),
          child: ListView.separated(
            itemBuilder: (context, index) {
              return _listTile(data[index]);
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: data.length,
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              // icon: const Icon(Icons.search),
              label: const Text('Search'),
              hintText: 'Search community',
              suffixIcon: ElevatedButton(
                child: const Text('Search'),
                onPressed: () {
                  setState(() {
                    _future = null;
                  });
                },
              ),
            ),
            autocorrect: false,
            enabled: true,
          ),
        ),
      ],
    );
  }

  Future<List<CommunityItem>> getListOfCommunities(String hiveApiUrl) {
    var value = searchController.value.text;
    return Communicator()
        .getListOfCommunities(value.isEmpty ? null : value, hiveApiUrl);
  }

  Widget _body(HiveUserData appData) {
    return FutureBuilder<List<CommunityItem>>(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return RetryScreen(
              error: snapshot.error?.toString() ?? "Something went wrong",
              onRetry: () {
                getListOfCommunities(appData.rpc);
              },
            );
          } else if (snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: _list(snapshot.data!.take(100).toList()),
            );
          } else {
            return RetryScreen(
              error: "Something went wrong",
              onRetry: () {
                getListOfCommunities(appData.rpc);
              },
            );
          }
        } else {
          return const LoadingScreen(
            title: 'Loading Data',
            subtitle: 'Please wait',
          );
        }
      },
      future: _future,
    );
  }

  @override
  Widget build(BuildContext context) {
    var appData = Provider.of<HiveUserData>(context);
    if (_future == null) {
      setState(() {
        _future = getListOfCommunities(appData.rpc);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communities"),
      ),
      body: _body(appData),
    );
  }
}
