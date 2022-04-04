import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/screens/about/about_home_screen.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:acela/src/screens/leaderboard_screen/leaderboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  Widget _homeMenu(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.home),
      title: const Text("Home"),
      onTap: () {
        Navigator.pop(context);
        var route = MaterialPageRoute(builder: (context) => HomeScreen.home());
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _firstUploads(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.emoji_emotions_outlined),
      title: const Text("First Uploads"),
      onTap: () {
        Navigator.pop(context);
        var route =
            MaterialPageRoute(builder: (context) => HomeScreen.firstUploads());
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _trendingContent(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.local_fire_department),
      title: const Text("Trending Content"),
      onTap: () {
        Navigator.pop(context);
        var route =
            MaterialPageRoute(builder: (context) => HomeScreen.trending());
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _newContent(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.play_arrow),
      title: const Text("New Content"),
      onTap: () {
        Navigator.pop(context);
        var route =
            MaterialPageRoute(builder: (context) => HomeScreen.newContent());
        Navigator.of(context).pushReplacement(route);
      },
    );
  }

  Widget _communities(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.people_sharp),
      title: const Text("Communities"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const CommunitiesScreen()));
      },
    );
  }

  Widget _leaderBoard(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.leaderboard),
      title: const Text("Leaderboard"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const LeaderboardScreen()));
      },
    );
  }

  Widget _changeTheme(BuildContext context) {
    var isDarkMode = Provider.of<bool>(context);
    return ListTile(
      leading: !isDarkMode
          ? const Icon(Icons.wb_sunny)
          : const Icon(Icons.mode_night),
      title: const Text("Change Theme"),
      onTap: () async {
        server.changeTheme(isDarkMode);
      },
    );
  }

  Widget _drawerHeader(BuildContext context) {
    return DrawerHeader(
      child: InkWell(
        child: Column(
          children: [
            Image.asset(
              "assets/branding/three_speak_icon.png",
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 5),
            Text(
              "Acela",
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 5),
            Text(
              "3Speak.tv",
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
        onTap: () {
          var screen = const AboutHomeScreen();
          var route = MaterialPageRoute(builder: (_) => screen);
          Navigator.of(context).push(route);
        },
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Colors.blueGrey,
    );
  }

  Widget _drawerMenu(BuildContext context) {
    return ListView(
      children: [
        _drawerHeader(context),
        _homeMenu(context),
        _divider(),
        _firstUploads(context),
        _divider(),
        _trendingContent(context),
        _divider(),
        _newContent(context),
        _divider(),
        _communities(context),
        _divider(),
        _leaderBoard(context),
        _divider(),
        _changeTheme(context),
        _divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: _drawerMenu(context));
  }
}
