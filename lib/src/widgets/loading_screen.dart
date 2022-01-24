import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(value: null,),
          Text('Loading Data', style: Theme.of(context).textTheme.bodyText1,),
          Text('Please wait', style: Theme.of(context).textTheme.bodyText2,),
        ],
      ),
    );
  }
}