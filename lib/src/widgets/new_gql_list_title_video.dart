import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/home_screen_feed_models/home_feed.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/seconds_to_duration.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class NewGQLListTitleVideo extends StatefulWidget {
  const NewGQLListTitleVideo({
    Key? key,
    required this.isAlternate,
    required this.user,
    required this.title,
    required this.permlink,
    required this.placeholder,
    required this.url,
    required this.created,
    required this.community,
    required this.data,
    required this.duration,
    required this.onUserTap,
  }) : super(key: key);

  final String url;
  final String user;
  final String title;
  final String permlink;
  final String placeholder;
  final bool isAlternate;
  final String? created;
  final String community;
  final HiveUserData data;
  final int? duration;
  final Function onUserTap;

  @override
  State<NewGQLListTitleVideo> createState() => _NewGQLListTitleVideoState();
}

class _NewGQLListTitleVideoState extends State<NewGQLListTitleVideo> {
  var payoutInfoText = "";

  void fetchHiveInfo(String user, String permlink, String hiveApiUrl,) async {
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
      var result = HivePostInfo
          .fromJsonString(string)
          .result
          .resultData
          .where((element) => element.permlink == permlink)
          .first;
      var upVotes = result.activeVotes
          .where((e) => e.rshares > 0)
          .length;
      var downVotes = result.activeVotes
          .where((e) => e.rshares < 0)
          .length;
      var upVotesText = "${upVotes > 0 ? " · 👍 $upVotes" : ""}";
      var downVotesText = "${downVotes > 0 ? " · 👎 $downVotes" : ""}";
      setState(() {
        payoutInfoText =
        "\n\$ ${result.payout.toStringAsFixed(3)}$upVotesText$downVotesText";
      });
    } else {
      print(response.reasonPhrase);
      throw response.reasonPhrase ?? 'Could not load hive payout info';
    }
  }


  @override
  void initState() {
    super.initState();
    fetchHiveInfo(widget.user, widget.permlink, widget.data.rpc);
  }

  Widget _errorIndicator() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image
              .asset(widget.placeholder)
              .image,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _newListTileItem(BuildContext context) {
    var isDarkMode = Provider.of<bool>(context);
    var created = DateTime.tryParse(widget.created ?? '');
    String timeInString =
    created != null ? "📆 ${timeago.format(created)}" : "";
    String duration = "🕚 ${Utilities.formatTime((widget.duration ?? 0).toInt())}";
    var color = isDarkMode
        ? widget.isAlternate
        ? Colors.white24
        : Colors.white12
        : widget.isAlternate
        ? Colors.black12
        : Colors.black38;
    return Container(
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            spreadRadius: 3,
            blurRadius: 3,
          )
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CustomCircleAvatar(
              height: 45,
              width: 45,
              url: server.userOwnerThumb(widget.user),
            ),
            title: Text(widget.user),
            trailing: Text('${widget.community} 🔖'),
            onTap: (){
              widget.onUserTap();
            },
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 220),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              title: FadeInImage.assetNetwork(
                placeholder: widget.placeholder,
                image: widget.url,
                fit: BoxFit.fitWidth,
                placeholderErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return _errorIndicator();
                },
                imageErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return _errorIndicator();
                },
              ),
            ),
          ),
          const SizedBox(height: 3),
          ListTile(
            title: Text(widget.title),
            subtitle: Text('$duration · $timeInString$payoutInfoText'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _newListTileItem(context);
  }
}
