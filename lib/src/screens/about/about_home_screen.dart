import 'package:acela/src/screens/about/about_faq.dart';
import 'package:acela/src/screens/about/about_us.dart';
import 'package:acela/src/screens/user_channel_screen/user_channel_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
              var screen = const AboutUsScreen();
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.question),
            title: const Text('FAQ'),
            onTap: () {
              var screen = const AboutFaqScreen();
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).push(route);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.twitter),
            title: const Text('Follow us on Twitter'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://twitter.com/3speakonline?utm_source=3speak.tv.acela'));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.telegram),
            title: const Text('Join us on Telegram'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://t.me/threespeak?utm_source=3speak.tv.acela'));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.discord),
            title: const Text('Join us on Discord'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://discord.me/3speak?utm_source=3speak.tv.acela'));
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.blog),
            title: const Text('Visit blog - hive.blog/@threespeak'),
            onTap: () {
              launchUrl(Uri.parse('https://hive.blog/@threespeak'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Visit website - spk.network'),
            onTap: () {
              launchUrl(Uri.parse('https://spk.network/'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.web),
            title: const Text('Visit website - 3speak.tv'),
            onTap: () {
              launchUrl(Uri.parse('https://3speak.tv/'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Terms of service'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://threespeakvideo.b-cdn.net/static/terms_of_service.pdf'));
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
