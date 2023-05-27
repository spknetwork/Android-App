import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;

class NewFeedListItem extends StatefulWidget {
  const NewFeedListItem({
    Key? key,
    required this.createdAt,
    required this.duration,
    required this.views,
    required this.thumbUrl,
    required this.author,
    required this.title,
    required this.rpc,
    required this.permlink,
  }) : super(key: key);

  final DateTime? createdAt;
  final double duration;
  final int views;
  final String thumbUrl;
  final String author;
  final String title;
  final String rpc;
  final String permlink;

  @override
  State<NewFeedListItem> createState() => _NewFeedListItemState();
}

class _NewFeedListItemState extends State<NewFeedListItem> {
  Widget listTile() {
    String timeInString = widget.createdAt != null
        ? "📝 ${timeago.format(widget.createdAt!)}"
        : "";
    String durationString =
        " 🕚 ${Utilities.formatTime(widget.duration.toInt())} ";
    String viewsString = "👁️ ${widget.views} views";
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          title: Image.network(
            widget.thumbUrl,
            fit: BoxFit.cover,
            height: 230,
          ),
          subtitle: ListTile(
            contentPadding: EdgeInsets.all(2),
            dense: true,
            leading: InkWell(
              child: CustomCircleAvatar(
                width: 40,
                height: 40,
                url: server.userOwnerThumb(widget.author),
              ),
              onTap: () {
                var screen = UserChannelScreen(owner: widget.author);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(context).push(route);
              },
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Text(widget.title),
            ),
            subtitle: Row(
              children: [
                InkWell(
                  child: Text('👤 ${widget.author}'),
                  onTap: () {
                    var screen = UserChannelScreen(owner: widget.author);
                    var route = MaterialPageRoute(builder: (c) => screen);
                    Navigator.of(context).push(route);
                  },
                ),
                SizedBox(width: 10),
                payoutInfo(),
              ],
            ),
          ),
          onTap: () {
            var viewModel = VideoDetailsViewModel(
              author: widget.author,
              permlink: widget.permlink,
            );
            var screen = VideoDetailsScreen(vm: viewModel);
            var route = MaterialPageRoute(builder: (context) => screen);
            Navigator.of(context).push(route);
          },
        ),
        Column(
          children: [
            const SizedBox(height: 208),
            Row(
              children: [
                SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      Text(timeInString, style: TextStyle(color: Colors.white)),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      Text(viewsString, style: TextStyle(color: Colors.white)),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(durationString,
                      style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 5),
              ],
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return listTile();
  }

  Future<PayoutInfo>? _fetchHiveInfo;

  Future<PayoutInfo> fetchHiveInfo(
      String user, String permlink, String hiveApiUrl) async {
    var request = http.Request('POST', Uri.parse('https://$hiveApiUrl'));
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
          return Text(priceAndVotes);
        } else {
          return const Text('Loading hive payout info');
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchHiveInfo = fetchHiveInfo(widget.author, widget.permlink, widget.rpc);
  }
}
