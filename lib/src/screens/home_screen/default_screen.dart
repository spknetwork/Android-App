import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/new_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DefaultView extends StatelessWidget {
  const DefaultView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<HiveUserData>(context);
    return userData.loaded
        ? userData.username != null
            ? GQLFeedScreen(appData: userData, username: userData.username!)
            : GQLFeedScreen(appData: userData, username: null)
        : Scaffold(
            appBar: AppBar(title: const Text('3Speak')),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
