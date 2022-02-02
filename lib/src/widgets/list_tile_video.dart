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
      required this.subtitle})
      : super(key: key);

  final String placeholder;
  final String url;
  final String userThumbUrl;
  final String title;
  final String subtitle;

  Widget _commonContainer(BuildContext context, Widget child) {
    return Container(
      child: child,
    );
  }

  Widget _listType(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double width = deviceWidth - 60 - 340;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(url, width: deviceWidth - width - 60, ),
        Container(width: 10),
        SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headline5,
              ),
              Container(height: 10),
              Text(subtitle, style: Theme.of(context).textTheme.headline6),
            ],
          ),
        )
      ],
    );
  }

  Widget _thumbnailType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInImage.assetNetwork(
          placeholder: placeholder,
          image: server.resizedImage(url),
          fit: BoxFit.cover,
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CustomCircleAvatar(height: 40, width: 40, url: userThumbUrl),
              Container(width: 5),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15),),
                    Container(height: 5),
                    Text(subtitle, style: const TextStyle(fontSize: 13),)
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
    ScreenType type = FormFactor.getFormFactor(context);
    Widget widget = type == ScreenType.desktop || type == ScreenType.tablet
        ? _listType(context)
        : _thumbnailType(context);
    return _commonContainer(context, widget);
  }
}
