import 'package:acela/src/bloc/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

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
    server.updateHiveUserData(null);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // ListTile(
            //   leading: const Icon(Icons.notifications),
            //   title: const Text('Manage Notifications'),
            //   onTap: () {
            //     var screen = ManageNotificationsScreen();
            //     var route = MaterialPageRoute(builder: (c) => screen);
            //     Navigator.of(context).push(route);
            //   },
            // ),
            _changeTheme(context),
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
