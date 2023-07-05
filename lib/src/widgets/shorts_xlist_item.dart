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

class ShortsXListItem extends StatefulWidget {
  const ShortsXListItem({
    Key? key,
    required this.createdAt,
    required this.duration,
    required this.views,
    required this.thumbUrl,
    required this.author,
    required this.title,
    required this.rpc,
    required this.permlink,
    required this.onTap,
    required this.onUserTap,
  }) : super(key: key);

  final DateTime? createdAt;
  final double? duration;
  final int? views;
  final String thumbUrl;
  final String author;
  final String title;
  final String rpc;
  final String permlink;
  final Function onTap;
  final Function onUserTap;

  @override
  State<ShortsXListItem> createState() => _ShortsXListItemState();
}

class _ShortsXListItemState extends State<ShortsXListItem> {
  Widget listTile() {
    String timeInString = widget.createdAt != null
        ? "📝 ${timeago.format(widget.createdAt!)}"
        : "";
    String durationString = widget.duration != null
        ? " 🕚 ${Utilities.formatTime(widget.duration!.toInt())} "
        : "";
    String viewsString =
    widget.views != null ? "👁️ ${widget.views} views" : "";
    return Stack(
      children: [
        ListTile(
          tileColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          title: Image.network(
            widget.thumbUrl,
            fit: BoxFit.fitHeight,
            height: 130,
            width: 65,
          ),
          // subtitle: ListTile(
          //   contentPadding: EdgeInsets.all(2),
          //   dense: true,
          //   leading: InkWell(
          //     child: CustomCircleAvatar(
          //       width: 40,
          //       height: 40,
          //       url: server.userOwnerThumb(widget.author),
          //     ),
          //     onTap: () {
          //       widget.onUserTap();
          //       var screen = UserChannelScreen(owner: widget.author);
          //       var route = MaterialPageRoute(builder: (c) => screen);
          //       Navigator.of(context).push(route);
          //     },
          //   ),
          //   title: Padding(
          //     padding: const EdgeInsets.only(bottom: 5.0),
          //     child: Text(widget.title),
          //   ),
          //   subtitle: Row(
          //     children: [
          //       InkWell(
          //         child: Text('👤 ${widget.author}'),
          //         onTap: () {
          //           widget.onUserTap();
          //           var screen = UserChannelScreen(owner: widget.author);
          //           var route = MaterialPageRoute(builder: (c) => screen);
          //           Navigator.of(context).push(route);
          //         },
          //       ),
          //       SizedBox(width: 10),
          //     ],
          //   ),
          // ),
          onTap: () {
            // widget.onTap();
            // var viewModel = VideoDetailsViewModel(
            //   author: widget.author,
            //   permlink: widget.permlink,
            // );
            // var screen = VideoDetailsScreen(vm: viewModel);
            // var route = MaterialPageRoute(builder: (context) => screen);
            // Navigator.of(context).push(route);
          },
        ),
        // Column(
        //   children: [
        //     const SizedBox(height: 208),
        //     Row(
        //       children: [
        //         SizedBox(width: 5),
        //         if (timeInString.isNotEmpty)
        //           Container(
        //             padding: EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.black,
        //               borderRadius: BorderRadius.circular(6),
        //             ),
        //             child: Text(timeInString,
        //                 style: TextStyle(color: Colors.white)),
        //           ),
        //         Spacer(),
        //         if (viewsString.isNotEmpty)
        //           Container(
        //             padding: EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.black,
        //               borderRadius: BorderRadius.circular(6),
        //             ),
        //             child: Text(viewsString,
        //                 style: TextStyle(color: Colors.white)),
        //           ),
        //         Spacer(),
        //         if (durationString.isNotEmpty)
        //           Container(
        //             padding: EdgeInsets.all(2),
        //             decoration: BoxDecoration(
        //               color: Colors.black,
        //               borderRadius: BorderRadius.circular(6),
        //             ),
        //             child: Text(durationString,
        //                 style: TextStyle(color: Colors.white)),
        //           ),
        //         SizedBox(width: 5),
        //       ],
        //     )
        //   ],
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return listTile();
  }
}
