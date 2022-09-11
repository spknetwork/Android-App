import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var res = '480p';

  @override
  void initState() {
    super.initState();
    loadRes();
  }

  void loadRes() async {
    const storage = FlutterSecureStorage();
    var newRes = await storage.read(key: 'resolution') ?? '480p';
    setState(() {
      res = newRes;
    });
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Colors.blueGrey,
    );
  }

  BottomSheetAction getAction(String optionName) {
    return BottomSheetAction(
      title: Text(optionName),
      onPressed: (context) async {
        Navigator.of(context).pop();
        const storage = FlutterSecureStorage();
        await storage.write(key: 'resolution', value: optionName);
        String? username = await storage.read(key: 'username');
        String? postingKey = await storage.read(key: 'postingKey');
        String? cookie = await storage.read(key: 'cookie');
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: postingKey,
            cookie: cookie,
            resolution: optionName,
          ),
        );
        loadRes();
      },
    );
  }

  void tappedVideoRes() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Set Default video resolution to'),
      androidBorderRadius: 30,
      actions: [getAction('480p'), getAction('720p'), getAction('1080p')],
      cancelAction: CancelAction(title: const Text('Cancel')),
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

  Widget _video(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.video_collection),
      title: const Text("Video Resolution"),
      subtitle: const Text("Change Default resolution"),
      trailing: Text(res),
      onTap: () async {
        tappedVideoRes();
      },
    );
  }

  Widget _drawerMenu(BuildContext context) {
    return ListView(
      children: [
        _changeTheme(context),
        _divider(),
        _video(context),
        _divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _drawerMenu(context),
    );
  }
}
