import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/about/about_home_screen.dart';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:acela/src/screens/leaderboard_screen/leaderboard_screen.dart';
import 'package:acela/src/screens/login/login_screen.dart';
import 'package:acela/src/screens/my_account/my_account_screen.dart';
import 'package:acela/src/screens/settings/settings_screen.dart';
import 'package:acela/src/screens/stories/stories_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (c) => CommunitiesScreen(
              didSelectCommunity: null,
            ),
          ),
        );
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

  Widget _shorts(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.video_camera_front_outlined),
      title: const Text("3Speak Shorts"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const StoriesScreen()));
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

  Widget _login(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.login),
      title: const Text("Log in"),
      onTap: () {
        Navigator.pop(context);
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (c) => const NewLoginScreen()));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const LoginScreen()));
      },
    );
  }

  Widget _myAccount(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: const Text("My account"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const MyAccountScreen()));
      },
    );
  }

  Widget _importantLinks(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.link),
      title: const Text("Important links"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const AboutHomeScreen()));
      },
    );
  }


  Widget _desktopApp() {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text("Desktop App"),
      onTap: () {
        Share.share('Download 3Speak on desktop at https://github.com/spknetwork/3Speak-app');
      },
    );
  }

  Widget _settings(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.settings),
      title: const Text("Settings"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (c) => const SettingsScreen()));
      },
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Colors.blueGrey,
    );
  }

  Widget _drawerMenu(BuildContext context) {
    var user = Provider.of<HiveUserData>(context);
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
        _shorts(context),
        _divider(),
        _desktopApp(),
        _settings(context),
        _divider(),
        user.username == null ? _login(context) : _myAccount(context),
        _divider(),
        _importantLinks(context),
        _divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: _drawerMenu(context));
  }
}
