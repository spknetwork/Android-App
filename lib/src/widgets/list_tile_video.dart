import 'package:flutter/material.dart';

import 'custom_circle_avatar.dart';

class ListTileVideo extends StatelessWidget {
  const ListTileVideo(
      {Key? key,
      required this.placeholder,
      required this.url,
      required this.userThumbUrl,
      required this.title,
      required this.subtitle})
      : super(key: key);

  final String placeholder;
  final String url;
  final String userThumbUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeInImage.assetNetwork(
            placeholder: placeholder,
            image: url,
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CustomCircleAvatar(height: 40, width: 40, url: userThumbUrl),
                Container(
                  width: 5,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.bodyText2),
                      Container(height: 5),
                      Text(subtitle,
                          style: Theme.of(context).textTheme.bodyText1)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
