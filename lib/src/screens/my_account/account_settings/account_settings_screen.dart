import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  void logout() async {
    // Create storage
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'postingKey');
    await storage.delete(key: 'cookie');
    await storage.delete(key: 'hasId');
    await storage.delete(key: 'hasExpiry');
    await storage.delete(key: 'hasAuthKey');
    String resolution = await storage.read(key: 'resolution') ?? '480p';
    String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
    server.updateHiveUserData(
      HiveUserData(
        username: null,
        postingKey: null,
        keychainData: null,
        cookie: null,
        resolution: resolution,
        rpc: rpc,
      ),
    );
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
