import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/global_provider/image_resolution_provider.dart';
import 'package:acela/src/global_provider/ipfs_node_provider.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/settings/add_cutom_union_indexer.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoLanguage {
  String name;
  String code;

  VideoLanguage({
    required this.name,
    required this.code,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var res = '480p';
  var languages = [
    VideoLanguage(code: "en", name: "English"),
    VideoLanguage(code: "de", name: "Deutsch"),
    VideoLanguage(code: "pt", name: "Portuguese"),
    VideoLanguage(code: "fr", name: "Français"),
    VideoLanguage(code: "es", name: "Español"),
    VideoLanguage(code: "nl", name: "Nederlands"),
    VideoLanguage(code: "ko", name: "한국어"),
    VideoLanguage(code: "ru", name: "русский"),
    VideoLanguage(code: "hu", name: "Magyar"),
    VideoLanguage(code: "ro", name: "Română"),
    VideoLanguage(code: "cs", name: "čeština"),
    VideoLanguage(code: "pl", name: "Polskie"),
    VideoLanguage(code: "in", name: "bahasa Indonesia"),
    VideoLanguage(code: "bn", name: "বাংলা"),
    VideoLanguage(code: "it", name: "Italian"),
    VideoLanguage(code: "he", name: "עִברִית"),
    VideoLanguage(code: "all", name: "All"),
  ];

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

  BottomSheetAction getAction(String optionName, HiveUserData appData) {
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
        String union = await storage.read(key: 'union') ??
            GQLCommunicator.defaultGQLServer;
        String? lang = await storage.read(key: 'lang');
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: postingKey,
            cookie: cookie,
            resolution: optionName,
            rpc: rpc,
            union: union,
            loaded: true,
            language: lang,
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

  void tappedVideoRes(HiveUserData appData) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Set Default video resolution to'),
      androidBorderRadius: 30,
      actions: [
        getAction('480p', appData),
        getAction('720p', appData),
        getAction('1080p', appData),
      ],
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

  BottomSheetAction getLangAction(
    VideoLanguage language,
    HiveUserData appData,
  ) {
    return BottomSheetAction(
      title: Text(language.name),
      onPressed: (context) async {
        Navigator.of(context).pop();
        const storage = FlutterSecureStorage();
        if (language.code == 'all') {
          await storage.delete(key: 'lang');
          await storage.delete(key: 'lang_display');
        } else {
          await storage.write(key: 'lang', value: language.code);
          await storage.write(key: 'lang_display', value: language.name);
        }
        server.updateHiveUserData(
          HiveUserData(
            username: appData.username,
            postingKey: appData.postingKey,
            cookie: appData.cookie,
            resolution: appData.resolution,
            rpc: appData.rpc,
            union: appData.union,
            loaded: true,
            language: language.code == 'all' ? null : language.code,
            keychainData: appData.keychainData,
          ),
        );
      },
    );
  }

  void tappedLanguage(HiveUserData appData) {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Set Default Language Filter'),
      androidBorderRadius: 30,
      actions: languages.map((e) => getLangAction(e, appData)).toList(),
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  Widget _appVersion(BuildContext context) {
    final String? appCurrentVersion =
        Upgrader.sharedInstance.currentInstalledVersion();
    final String? newAvailableVersion =
        Upgrader.sharedInstance.currentAppStoreVersion();
    return ListTile(
      leading: const Icon(Icons.app_settings_alt_sharp),
      title: Text("Current Version $appCurrentVersion"),
      subtitle: Text("Latest Version $newAvailableVersion"),
      trailing: Visibility(
        visible: appCurrentVersion != newAvailableVersion,
        child: TextButton(
          onPressed: () async {
            String url = "";
            if (defaultTargetPlatform == TargetPlatform.android) {
              url =
                  "https://play.google.com/store/apps/details?id=tv.threespeak.app";
            } else if (defaultTargetPlatform == TargetPlatform.iOS) {
              url = "https://apps.apple.com/us/app/3speak/id1614771373";
            }
            if (await canLaunchUrl(Uri.parse(url))) {
              launchUrl(Uri.parse(url));
            }
          },
          child: Text("Update"),
        ),
      ),
    );
  }

  Widget _changeLanguage(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    var display =
        languages.where((e) => e.code == data.language).firstOrNull?.name ??
            'All Languages';
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text("Set Language Filter"),
      trailing: Text(display),
      onTap: () {
        tappedLanguage(data);
      },
    );
  }

  Widget _video(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return ListTile(
      leading: const Icon(Icons.video_collection),
      title: const Text("Video Resolution"),
      subtitle: Text(res),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () async {
        tappedVideoRes(data);
      },
    );
  }

  Widget _image(BuildContext context) {
    return Selector<ImageResolution, String>(
      selector: (_, myType) => myType.resolution,
      builder: (context, value, child) {
        return ListTile(
          leading: const Icon(Icons.image),
          title: const Text("Image Resolution"),
          subtitle: Text(value),
          trailing: Icon(Icons.arrow_drop_down),
          onTap: () async {
            tappedImageRes();
          },
        );
      },
    );
  }

  void tappedImageRes() {
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Set Default video Image resolution to'),
      androidBorderRadius: 30,
      actions: [
        getImageResolutionAction(Resolution.r360),
        getImageResolutionAction(Resolution.r480),
        getImageResolutionAction(Resolution.r720),
        getImageResolutionAction(Resolution.r1080),
      ],
      cancelAction: CancelAction(title: const Text('Cancel')),
    );
  }

  BottomSheetAction getImageResolutionAction(
    String resolution,
  ) {
    return BottomSheetAction(
      title: Text(resolution),
      onPressed: (context) async {
        Navigator.of(context).pop();
        context.read<ImageResolution>().resolution = resolution;
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
            union: user.union,
            rpc: serverUrl,
            loaded: true,
            language: user.language,
          ),
        );
      },
    );
  }

  void showBottomSheetForServer(HiveUserData user) {
    var list = [
      'api.hive.blog',
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
      title: const Text("Hive API Node (RPC)"),
      subtitle: Text(user.rpc),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () {
        showBottomSheetForServer(user);
      },
    );
  }

  BottomSheetAction getActionForUnionIndexer(
      String serverUrl, HiveUserData user) {
    return BottomSheetAction(
      title: Text(serverUrl),
      onPressed: (context) async {
        Navigator.of(context).pop();
        await _saveUnionIndexer(serverUrl, user);
      },
    );
  }

  Future<void> _saveUnionIndexer(String serverUrl, HiveUserData user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'union', value: serverUrl);
    server.updateHiveUserData(
      HiveUserData(
        username: user.username,
        postingKey: user.postingKey,
        keychainData: user.keychainData,
        cookie: user.cookie,
        resolution: user.resolution,
        union: serverUrl,
        rpc: user.rpc,
        loaded: true,
        language: user.language,
      ),
    );
  }

  void showBottomSheetForUnionIndexer(HiveUserData user) {
    List<String> nodes = [];
    nodes.add(GQLCommunicator.defaultGQLServer);
    if (user.union != GQLCommunicator.defaultGQLServer) {
      nodes.add(user.union);
    }
    var list = nodes.map((e) => getActionForUnionIndexer(e, user)).toList();
    list.add(BottomSheetAction(
      title: Text('Custom'),
      onPressed: (context) async {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddNodeByUrl(
              title: 'union indexer',
              onAdd: (serverUrl) async {
                Navigator.pop(context);
                await _saveUnionIndexer(serverUrl, user);
              },
            ),
          ),
        );
      },
    ));
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Select Union Indexer API Node'),
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

  Widget _unionIndexer(BuildContext context, HiveUserData user) {
    return ListTile(
      leading: const Icon(Icons.computer),
      title: const Text("Union Indexer API Node"),
      subtitle: Text(user.union),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () {
        showBottomSheetForUnionIndexer(user);
      },
    );
  }

  Widget _ipfsNode() {
    return ListTile(
      leading: const Icon(Icons.note_rounded),
      title: const Text("IPFS Node"),
      subtitle: Text(IpfsNodeProvider().nodeUrl),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: () {
        showIpfsNodeBottomSheet();
      },
    );
  }

  void showIpfsNodeBottomSheet() {
    List<String> nodes = [];
    nodes.add(IpfsNodeProvider().defaultIpfsNode);
    if (IpfsNodeProvider().nodeUrl != IpfsNodeProvider().defaultIpfsNode) {
      nodes.add(IpfsNodeProvider().nodeUrl);
    }
    var list = nodes.map((e) => _ipfsBottomSheetAction(e)).toList();
    list.add(BottomSheetAction(
      title: Text('Custom'),
      onPressed: (context) async {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddNodeByUrl(
              title: 'IPFS node',
              onAdd: (serverUrl) async {
                Navigator.pop(context);
                setState(() {
                  IpfsNodeProvider().changeIpfsNode(serverUrl);
                });
              },
            ),
          ),
        );
      },
    ));
    showAdaptiveActionSheet(
      context: context,
      title: const Text('Select IPFS Node'),
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

  BottomSheetAction _ipfsBottomSheetAction(String url) {
    return BottomSheetAction(
      title: Text(url),
      onPressed: (context) async {
        Navigator.pop(context);
        setState(() {
          IpfsNodeProvider().changeIpfsNode(url);
        });
      },
    );
  }

  Widget _drawerMenu(BuildContext context, HiveUserData user) {
    return ListView(
      children: [
        _changeLanguage(context),
        _divider(),
        _changeTheme(context),
        _divider(),
        _video(context),
        _divider(),
        _image(context),
        _divider(),
        _rpc(context, user),
        _divider(),
        _unionIndexer(context, user),
        _divider(),
        _ipfsNode(),
        _divider(),
        _appVersion(context),
        _divider(),
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
