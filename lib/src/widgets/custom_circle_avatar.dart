import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  const CustomCircleAvatar(
      {Key? key, required this.height, required this.width, required this.url})
      : super(key: key);
  final double height;
  final double width;
  final String url;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircleAvatar(
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.transparent,
        radius: 100,
      ),
    );
  }
}
