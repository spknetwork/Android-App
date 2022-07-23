import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key, required this.title, required this.subtitle})
      : super(key: key);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          const CircularProgressIndicator(
            value: null,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
