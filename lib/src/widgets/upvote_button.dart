import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/login/ha_login_screen.dart';
import 'package:acela/src/screens/video_details_screen/hive_upvote_dialog.dart';
import 'package:acela/src/utils/graphql/models/trending_feed_response.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

class UpvoteButton extends StatefulWidget {
  const UpvoteButton(
      {Key? key, required this.appData, required this.item, this.votes})
      : super(key: key);

  final HiveUserData appData;
  final GQLFeedItem item;
  final int? votes;

  @override
  State<UpvoteButton> createState() => _UpvoteButtonState();
}

class _UpvoteButtonState extends State<UpvoteButton> {
  late int votes;
  @override
  void initState() {
    votes = widget.votes ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: Row(
        children: [
          SizedBox(
            height: 15,
            width: 25,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: upvotePressed,
              icon: Icon(
                Icons.thumb_up_sharp,
                size: 14,
              ),
            ),
          ),
          Text(
            ' $votes',
            style: TextStyle(
                color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  void upvotePressed() {
    if (widget.appData.username == null) {
      showAdaptiveActionSheet(
        context: context,
        title: const Text('You are not logged in. Please log in to upvote.'),
        androidBorderRadius: 30,
        actions: [
          BottomSheetAction(
              title: Text('Log in'),
              leading: Icon(Icons.login),
              onPressed: (c) {
                Navigator.of(c).pop();
                var screen = HiveAuthLoginScreen(appData: widget.appData);
                var route = MaterialPageRoute(builder: (c) => screen);
                Navigator.of(c).push(route);
              }),
        ],
        cancelAction: CancelAction(title: const Text('Cancel')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HiveUpvoteDialog(
          author: widget.item.author!.username ?? 'sagarkothari88',
          permlink: widget.item.permlink ?? 'ctbtwcxbbd',
          username: widget.appData.username ?? "",
          hasKey: widget.appData.keychainData?.hasId ?? "",
          hasAuthKey: widget.appData.keychainData?.hasAuthKey ?? "",
          activeVotes: [],
          onClose: () {},
          onDone: () {
            setState(() {
              votes++;
            });
          },
        );
      },
    );
  }
}
