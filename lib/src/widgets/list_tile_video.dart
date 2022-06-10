import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'custom_circle_avatar.dart';

class ListTileVideo extends StatefulWidget {
  const ListTileVideo({
    Key? key,
    required this.placeholder,
    required this.url,
    required this.userThumbUrl,
    required this.title,
    required this.subtitle,
    required this.onUserTap,
    required this.user,
    required this.permlink,
    required this.shouldResize,
  }) : super(key: key);

  final String placeholder;
  final String url;
  final String userThumbUrl;
  final String title;
  final String subtitle;
  final Function onUserTap;
  final String user;
  final String permlink;
  final bool shouldResize;

  @override
  State<ListTileVideo> createState() => _ListTileVideoState();
}

class _ListTileVideoState extends State<ListTileVideo> {
  late Future<PayoutInfo> _fetchHiveInfo;

  @override
  void initState() {
    super.initState();
    _fetchHiveInfo = fetchHiveInfo(widget.user, widget.permlink);
  }

  Widget _errorIndicator() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(widget.placeholder).image,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Future<PayoutInfo> fetchHiveInfo(String user, String permlink) async {
    var request = http.Request('POST', Uri.parse('https://api.hive.blog/'));
    request.body = json.encode({
      "id": 1,
      "jsonrpc": "2.0",
      "method": "bridge.get_discussion",
      "params": {"author": user, "permlink": permlink, "observer": ""}
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      var result = HivePostInfo.fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == permlink)
          .first;
      var upVotes = result.activeVotes.where((e) => e.rshares > 0).length;
      var downVotes = result.activeVotes.where((e) => e.rshares < 0).length;
      return PayoutInfo(
        payout: result.payout,
        downVotes: downVotes,
        upVotes: upVotes,
      );
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Could not load hive payout info';
    }
  }

  Widget payoutInfo() {
    return FutureBuilder(
      future: _fetchHiveInfo,
      builder: (builder, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading hive payout info');
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          var data = snapshot.data as PayoutInfo;
          String priceAndVotes =
              "\$ ${data.payout?.toStringAsFixed(3)} · 👍 ${data.upVotes} · 👎 ${data.downVotes}";
          return Text(priceAndVotes,
              style: Theme.of(context).textTheme.bodyText2);
        } else {
          return const Text('Loading hive payout info');
        }
      },
    );
  }

  Widget _thumbnailType(BuildContext context) {
    var isDarkMode = Provider.of<bool>(context);
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: isDarkMode ? Colors.black26 : Colors.black12,
          spreadRadius: 3,
          blurRadius: 3,
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            width: MediaQuery.of(context).size.width,
            child: FadeInImage.assetNetwork(
              placeholder: widget.placeholder,
              image: widget.shouldResize
                  ? server.resizedImage(widget.url)
                  : widget.url,
              fit: BoxFit.fitWidth,
              placeholderErrorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return _errorIndicator();
              },
              imageErrorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return _errorIndicator();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: InkWell(
                    child: Column(
                      children: [
                        CustomCircleAvatar(
                            height: 45, width: 45, url: widget.userThumbUrl),
                        SizedBox(height: 3),
                        Text(widget.user,
                            style: Theme.of(context).textTheme.bodyText2),
                      ],
                    ),
                    onTap: () {
                      widget.onUserTap();
                    },
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(height: 2),
                      Text(widget.subtitle,
                          style: Theme.of(context).textTheme.bodyText2),
                      SizedBox(height: 2),
                      payoutInfo(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailType(context);
  }
}
