import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/utils/form_factor.dart';
import 'package:flutter/material.dart';
import 'custom_circle_avatar.dart';
import '../utils/form_factor.dart';

class ListTileVideo extends StatelessWidget {
  const ListTileVideo(
      {Key? key,
      required this.placeholder,
      required this.url,
      required this.userThumbUrl,
      required this.title,
      required this.subtitle,
      required this.onUserTap})
      : super(key: key);

  final String placeholder;
  final String url;
  final String userThumbUrl;
  final String title;
  final String subtitle;
  final Function onUserTap;

  Widget _thumbnailType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          width: MediaQuery.of(context).size.width,
          child: FadeInImage.assetNetwork(
            placeholder: placeholder,
            image: server.resizedImage(url),
            fit: BoxFit.fitWidth,
            placeholderErrorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              return Image.asset(placeholder);
            },
            imageErrorBuilder: (BuildContext context, Object error, StackTrace? stackTrace){
              return Image.asset(placeholder);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              GestureDetector(
                child: CustomCircleAvatar(
                    height: 45, width: 45, url: userThumbUrl),
                onTap: () {
                  onUserTap();
                },
              ),
              Container(width: 5),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyText1),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyText2),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailType(context);
  }
}
