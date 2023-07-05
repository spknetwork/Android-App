import 'dart:core';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/leaderboard_models/leaderboard_model.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({
    Key? key,
    required this.withoutScaffold,
  }) : super(key: key);
  final bool withoutScaffold;

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Future<List<LeaderboardResponseItem>> getData() async {
    var response = await get(Uri.parse("${server.domain}/apiv2/leaderboard"));
    if (response.statusCode == 200) {
      return leaderboardResponseItemFromString(response.body);
    } else {
      throw "Status code not 200";
    }
  }

  Widget _listTileSubtitle(LeaderboardResponseItem item, double max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rank: ${item.rank}\nScore: ${item.score}"),
        Container(
          height: 5,
        ),
        LinearProgressIndicator(
          value: item.score / max,
        )
      ],
    );
  }

  void onUserTap(String author) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (c) => UserChannelScreen(owner: author)));
  }

  Widget _medalTile(LeaderboardResponseItem item, String medal, double max) {
    return ListTile(
      leading: CustomCircleAvatar(
        width: 60,
        height: 60,
        url: server.userOwnerThumb(item.username),
      ),
      title: Row(
        children: [
          CircleAvatar(
            child: Text(medal),
            backgroundColor: Colors.transparent,
          ),
          Text(item.username),
        ],
      ),
      subtitle: _listTileSubtitle(item, max),
      onTap: () {
        onUserTap(item.username);
      },
    );
  }

  Widget _listTile(LeaderboardResponseItem item, double max) {
    return ListTile(
      leading: CustomCircleAvatar(
        width: 60,
        height: 60,
        url: server.userOwnerThumb(item.username),
      ),
      title: Text(item.username),
      subtitle: _listTileSubtitle(item, max),
      onTap: () {
        onUserTap(item.username);
      },
    );
  }

  Widget _list(List<LeaderboardResponseItem> data) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return index == 0
              ? _medalTile(data[index], '🥇', data[0].score)
              : index == 1
                  ? _medalTile(data[index], '🥈', data[0].score)
                  : index == 2
                      ? _medalTile(data[index], '🥉', data[0].score)
                      : _listTile(data[index], data[0].score);
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: data.length);
  }

  Widget _body() {
    return FutureBuilder<List<LeaderboardResponseItem>>(
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
                child: _list(snapshot.data!.take(100).toList()),
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
    if (widget.withoutScaffold) {
      return _body();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Leaderboard"),
        ),
        body: _body(),
      );
    }
  }
}
