import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutHomeScreen extends StatelessWidget {
  const AboutHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3Speak.tv'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About us'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.question),
            title: const Text('FAQ'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.twitter),
            title: const Text('Follow us on Twitter'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.telegram),
            title: const Text('Join us on Telegram'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.discord),
            title: const Text('Join us on Discord'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.blog),
            title: const Text('Visit blog - hive.blog/@threespeak'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Visit website - spk.network'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Visit website - 3speak.tv'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Terms of service'),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Who built this app?'),
            onTap: () {
              var screen = const UserChannelScreen(owner: 'sagarkothari88');
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            },
          ),
        ],
      ),
    );
  }
}
