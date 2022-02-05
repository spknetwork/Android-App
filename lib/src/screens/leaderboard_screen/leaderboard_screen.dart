import 'dart:developer';
import 'dart:core';
import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/leaderboard_models/leaderboard_model.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

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

  Widget _body() {
    return FutureBuilder<List<LeaderboardResponseItem>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return RetryScreen(
                error: snapshot.error?.toString() ?? "Something went wrong",
                onRetry: getData,
              );
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              return ListView.separated(itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Image.network(
                      server.userOwnerThumb(data[index].username)),),
                  title: Text(data[index].username),
                  subtitle: Text(
                      "Rank: ${data[index].rank}\nScore: ${data[index].score}"),
                  onTap: () {
                    log("user tapped on ${data[index].username}");
                  },
                );
              },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: data.length);
            } else {
              return RetryScreen(
                error: "Something went wrong",
                onRetry: getData,
              );
            }
          } else {
            return const LoadingScreen();
          }
        },
        future: getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
      ),
      body: _body(),
    );
  }
}
