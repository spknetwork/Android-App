import 'package:acela/src/bloc/server.dart';
import 'package:flutter/material.dart';
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
    required this.payout,
    required this.upVotes,
    required this.downVotes,
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
  final double? payout;
  final int? upVotes;
  final int? downVotes;

  @override
  State<ListTileVideo> createState() => _ListTileVideoState();
}

class _ListTileVideoState extends State<ListTileVideo> {
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

  Widget _thumbnailType(BuildContext context) {
    String priceAndVotes = (widget.payout != null &&
            widget.upVotes != null &&
            widget.downVotes != null)
        ? "\$ ${widget.payout!.toStringAsFixed(3)} · 👍 ${widget.upVotes} · 👎 ${widget.downVotes}"
        : "";
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
                      Text(priceAndVotes,
                          style: Theme.of(context).textTheme.bodyText2),
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
