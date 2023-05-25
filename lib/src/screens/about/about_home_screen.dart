import 'package:acela/src/screens/about/about_faq.dart';
import 'package:acela/src/screens/about/about_us.dart';
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
                  'https://twitter.com/3speakonline??utm_source=3speak.tv.acela'));
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
                  'https://discord.gg/NSFS2VGj83?utm_source=3speak.tv.acela'));
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
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Terms of service'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://threespeakvideo.b-cdn.net/static/terms_of_service.pdf'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text('Vote for 3Speak proposal'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://peakd.com/hive-112019/@spknetwork/spk-network-funding-proposal-rhnv7e'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_iphone),
            title: const Text('Download iOS App'),
            onTap: () {
              launchUrl(
                  Uri.parse('https://apps.apple.com/us/app/3speak/id1614771373'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.android),
            title: const Text('Download Android App'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://play.google.com/store/apps/details?id=tv.threespeak.app'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: const Text('Download Android App via DropBox'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://www.dropbox.com/sh/a0q5u7l3j9ygzty/AABAqtxnLrPBYbk4q5H9BBWja?dl=0'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('Contact Dev - @sagarkothari88'),
            onTap: () {
              launchUrl(Uri.parse(
                  'https://hivesigner.com/sign/account-witness-vote?witness=sagarkothari88&approve=1'));
            },
          ),
        ],
      ),
    );
  }
}
