import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          const CircularProgressIndicator(value: null,),
          const SizedBox(height: 20,),
          Text('Loading Data', style: Theme.of(context).textTheme.bodyText1,),
          const SizedBox(height: 10,),
          Text('Please wait', style: Theme.of(context).textTheme.bodyText2,),
          const Spacer(),
        ],
      ),
    );
  }
}