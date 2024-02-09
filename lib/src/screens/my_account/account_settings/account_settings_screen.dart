import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/new_home_screen.dart';
import 'package:acela/src/screens/my_account/account_settings/widgets/delete_dialog.dart';
import 'package:acela/src/screens/my_account/account_settings/widgets/dialog_button.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  bool isLoading = false;
  Future<void> logout(HiveUserData data) async {
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
    String union =
        await storage.read(key: 'union') ?? GQLCommunicator.defaultGQLServer;
    String? lang = await storage.read(key: 'lang');
    var newUserData = HiveUserData(
      username: null,
      postingKey: null,
      keychainData: null,
      accessToken: null,
      resolution: resolution,
      rpc: rpc,
      union: union,
      loaded: true,
      language: lang,
    );
    server.updateHiveUserData(newUserData);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            GQLFeedScreen(appData: newUserData, username: null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log Out'),
                    onTap: () {
                      logout(data);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      deleteDialog(data);
                    },
                  ),
                ],
              ),
      ),
    );
  }

  void deleteDialog(HiveUserData data) {
    showDialog(
      barrierDismissible: true,
      useRootNavigator: true,
      context: context,
      builder: (context) {
        return DeleteDialog(
          onDelete: () async {
            Navigator.pop(context);
            try {
              /*
              // TO-DO: New Acela Core APIs
              setState(() {
                isLoading = true;
              });
              bool status = await Communicator().deleteAccount(data);
              log(status.toString());
              if (status) {
                await logout(data);
                showMessage('Account Deleted Successfully');
              } else {
                showError("Sorry, Something went wrong.");
              }
              setState(() {
                isLoading = false;
              });
               */
            } catch (e) {
              setState(() {
                isLoading = false;
              });
              showError("Sorry, Something went wrong.");
            }
          },
        );
      },
    );
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
