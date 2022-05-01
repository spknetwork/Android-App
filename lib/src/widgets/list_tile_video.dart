import 'package:acela/src/bloc/server.dart';
import 'package:flutter/material.dart';

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

  Widget _amount(String string) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadiusDirectional.all(Radius.circular(10)),
                    color: Colors.blueGrey),
                child: Text(string),
              ),
              const SizedBox(height: 5),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _hivePayoutLoader() {
    String priceAndVotes = (widget.payout != null &&
            widget.upVotes != null &&
            widget.downVotes != null)
        ? "\$ ${widget.payout!.toStringAsFixed(3)} · 👍 ${widget.upVotes} · 👎 ${widget.downVotes}"
        : "";
    return _amount(priceAndVotes);
  }

  Widget _thumbnailType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
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
            _hivePayoutLoader(),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              InkWell(
                child: CustomCircleAvatar(
                    height: 45, width: 45, url: widget.userThumbUrl),
                onTap: () {
                  widget.onUserTap();
                },
              ),
              SizedBox(width: 5),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: Theme.of(context).textTheme.bodyText1),
                    SizedBox(height: 5),
                    InkWell(
                      child: Text('👤 ${widget.user}',
                          style: Theme.of(context).textTheme.bodyText2),
                      onTap: () {
                        widget.onUserTap();
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Center(
            child: Text(widget.subtitle,
                style: Theme.of(context).textTheme.bodyText2)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailType(context);
  }
}
