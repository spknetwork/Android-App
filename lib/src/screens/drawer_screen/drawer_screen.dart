import 'package:flutter/material.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen(
      {Key? key, required this.isDarkMode, required this.switchDarkMode})
      : super(key: key);

  final bool isDarkMode;
  final Function switchDarkMode;

  Widget _homeMenu(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.home),
      title: const Text("Home"),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _firstUploads() {
    return ListTile(
      leading: const Icon(Icons.emoji_emotions_outlined),
      title: const Text("First Uploads"),
      onTap: () {},
    );
  }

  Widget _trendingContent(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.local_fire_department),
      title: const Text("Trending Content"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/trending");
      },
    );
  }

  Widget _newContent(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.play_arrow),
      title: const Text("New Content"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/new");
      },
    );
  }

  Widget _communities() {
    return ListTile(
      leading: const Icon(Icons.people_sharp),
      title: const Text("Communities"),
      onTap: () {},
    );
  }

  Widget _leaderBoard(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.leaderboard),
      title: const Text("Leaderboard"),
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed("/leaderboard");
      },
    );
  }

  Widget _changeTheme() {
    return ListTile(
      leading: isDarkMode
          ? const Icon(Icons.wb_sunny)
          : const Icon(Icons.mode_night),
      title: const Text("Change Theme"),
      onTap: () {
        switchDarkMode();
      },
    );
  }

  Widget _drawerHeader(BuildContext context) {
    return DrawerHeader(
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
    );
  }

  Widget _drawerMenu(BuildContext context) {
    return ListView(
      children: [
        _drawerHeader(context),
        _homeMenu(context),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _firstUploads(),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _trendingContent(context),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _newContent(context),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _communities(),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _leaderBoard(context),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
        _changeTheme(),
        const Divider(
          height: 1,
          color: Colors.blueGrey,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(child: _drawerMenu(context));
  }
}
