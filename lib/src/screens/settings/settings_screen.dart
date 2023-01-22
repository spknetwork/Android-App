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
        String? hasId = await storage.read(key: 'hasId');
        String? hasExpiry = await storage.read(key: 'hasExpiry');
        String? hasAuthKey = await storage.read(key: 'hasAuthKey');
        String? cookie = await storage.read(key: 'cookie');
        String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: postingKey,
            cookie: cookie,
            resolution: optionName,
            rpc: rpc,
            keychainData: hasId != null &&
                    hasId.isNotEmpty &&
                    hasExpiry != null &&
                    hasExpiry.isNotEmpty &&
                    hasAuthKey != null &&
                    hasAuthKey.isNotEmpty
                ? HiveKeychainData(
                    hasAuthKey: hasAuthKey,
                    hasExpiry: hasExpiry,
                    hasId: hasId,
                  )
                : null,
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

  BottomSheetAction getActionForRpc(String serverUrl, HiveUserData user) {
    return BottomSheetAction(
      title: Text(serverUrl),
      onPressed: (context) async {
        Navigator.of(context).pop();
        const storage = FlutterSecureStorage();
        await storage.write(key: 'rpc', value: serverUrl);
        server.updateHiveUserData(
          HiveUserData(
            username: user.username,
            postingKey: user.postingKey,
            keychainData: user.keychainData,
            cookie: user.cookie,
            resolution: user.resolution,
            rpc: serverUrl,
          ),
        );
      },
    );
  }

  void showBottomSheetForServer(HiveUserData user) {
    var list = [
      'api.hive.blog',
      'api.deathwing.me',
      'hive-api.arcange.eu',
      'hived.emre.sh',
      'api.openhive.network',
      'rpc.ausbit.dev',
      'anyx.io',
      'techcoderx.com',
      'api.hive.blue',
      'api.pharesim.me',
      'hived.privex.io',
      'hive.roelandp.nl',
    ].map((e) => getActionForRpc(e, user)).toList();
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Select Hive API Node (RPC)'),
      androidBorderRadius: 30,
      actions: list,
      cancelAction: CancelAction(
        title: const Text(
          'Cancel',
          style: TextStyle(color: Colors.deepOrange),
        ),
      ),
    );
  }

  Widget _rpc(BuildContext context, HiveUserData user) {
    return ListTile(
      leading: const Icon(Icons.cloud),
      title: const Text("Change Hive API Node (RPC)"),
      subtitle: Text(user.rpc),
      onTap: () {
        showBottomSheetForServer(user);
      },
    );
  }

  Widget _drawerMenu(BuildContext context, HiveUserData user) {
    return ListView(
      children: [
        _changeTheme(context),
        _divider(),
        _video(context),
        _divider(),
        _rpc(context, user)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _drawerMenu(context, user),
    );
  }
}
