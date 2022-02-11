import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/communities_models/request/communities_request_model.dart';
import 'package:acela/src/models/communities_models/response/communities_response_models.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:acela/src/widgets/retry.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({Key? key}) : super(key: key);

  @override
  _CommunitiesScreenState createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  Future<List<CommunityItem>> getData() async {
    var client = http.Client();
    var body = communitiesRequestModelToJson(
        CommunitiesRequestModel(params: CommunitiesRequestParams()));
    var response = await client.post(Uri.parse(server.hiveDomain), body: body);
    if (response.statusCode == 200) {
      var communitiesResponse =
          communitiesResponseModelFromString(response.body);
      return communitiesResponse.result;
    } else {
      throw "Status code is ${response.statusCode}";
    }
  }

  Widget _listTile(CommunityItem item) {
    return ListTile(
      leading: CustomCircleAvatar(
        width: 60,
        height: 60,
        url: server.communityIcon(item.name),
      ),
      title: Text(item.title),
      subtitle: Text(item.about),
      onTap: () {
        log("user tapped on ${item.name}");
      },
    );
  }

  Widget _list(List<CommunityItem> data) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return _listTile(data[index]);
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: data.length);
  }

  Widget _body() {
    return FutureBuilder<List<CommunityItem>>(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return RetryScreen(
                error: snapshot.error?.toString() ?? "Something went wrong",
                onRetry: getData,
              );
            } else if (snapshot.hasData) {
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
            return const LoadingScreen();
          }
        },
        future: getData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Communities"),
      ),
      body: _body(),
    );
  }
}
