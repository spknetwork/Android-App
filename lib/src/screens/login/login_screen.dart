import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/crypto_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isLoading = false;
  static const platform = MethodChannel('com.example.acela/auth');
  var username = '';
  var postingKey = '';

  // Create storage
  static const storage = FlutterSecureStorage();

  void onLoginTapped(HiveUserData appData) async {
    setState(() {
      isLoading = true;
    });
    try {
      var publicKey = await Communicator().getPublicKey(username, appData.rpc);
      var resultingKey = CryptoManager().privToPub(postingKey);
      if (resultingKey == publicKey) {
        // it is valid key
        debugPrint("Successful login");
        String resolution = await storage.read(key: 'resolution') ?? '480p';
        String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'postingKey', value: postingKey);
        await storage.delete(key: 'hasId');
        await storage.delete(key: 'hasExpiry');
        await storage.delete(key: 'hasAuthKey');
        await storage.delete(key: 'cookie');
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: postingKey,
            keychainData: null,
            cookie: null,
            resolution: resolution,
            rpc: rpc,
          ),
        );
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;
        });
      } else {
        // it is NO valid key
        showError('Not valid key.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showError('Error occurred - ${e.toString()}');
    }
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _hiveUserName() {
    return TextField(
      decoration: InputDecoration(
        icon: const Icon(Icons.person),
        label: const Text('Hive Username'),
        hintText: 'Enter Hive username here',
      ),
      autocorrect: false,
      onChanged: (value) {
        setState(() {
          username = value;
        });
      },
      enabled: isLoading ? false : true,
    );
  }

  Widget _hivePostingKey() {
    return TextField(
      decoration: InputDecoration(
        icon: const Icon(Icons.key),
        label: const Text('Hive Posting Key'),
        hintText: 'Copy & paste posting key here',
      ),
      obscureText: true,
      onChanged: (value) {
        setState(() {
          postingKey = value;
        });
      },
      enabled: isLoading ? false : true,
    );
  }

  Widget _hasButton() {
    return ElevatedButton(
      onPressed: () async {
        if (username.isNotEmpty) {
          var platform = const MethodChannel('blog.hive.auth/bridge');
          var values = await platform.invokeMethod('getUserInfo');
          var valuesResponse = LoginBridgeResponse.fromJsonString(values);
          if (valuesResponse.data?.startsWith("undefined,undefined") == true) {
            final String authStr =
                await platform.invokeMethod('getRedirectUri', {
              'username': username,
            });
            log('Hive auth string is $authStr');
            var bridgeResponse = LoginBridgeResponse.fromJsonString(authStr);
            if (bridgeResponse.data != null) {
              var url = Uri.parse(bridgeResponse.data!);
              launchUrl(url);
            }
          } else {
            debugPrint("Successful login");
            String resolution = await storage.read(key: 'resolution') ?? '480p';
            String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
            var hasId = valuesResponse.data!.split(",")[0];
            var hasExpiry = valuesResponse.data!.split(",")[1];
            var hasAuthKey = valuesResponse.data!.split(",")[2];
            await storage.write(key: 'username', value: username);
            await storage.write(key: 'hasId', value: hasId);
            await storage.write(key: 'hasExpiry', value: hasExpiry);
            await storage.write(key: 'hasAuthKey', value: hasAuthKey);
            await storage.delete(key: 'cookie');
            server.updateHiveUserData(
              HiveUserData(
                username: username,
                postingKey: null,
                keychainData: HiveKeychainData(
                  hasId: hasId,
                  hasExpiry: hasExpiry,
                  hasAuthKey: hasAuthKey,
                ),
                cookie: null,
                resolution: resolution,
                rpc: rpc,
              ),
            );
            Navigator.of(context).pop();
            setState(() {
              isLoading = false;
            });
          }
        } else {
          showError('Please enter hive username');
        }
      },
      child: Image.asset('assets/hive-keychain-image.png'),
    );
  }

  Widget _loginForm(HiveUserData appData) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          _hiveUserName(),
          SizedBox(height: 20),
          _hasButton(),
          SizedBox(height: 50),
          const Text('- OR -'),
          _hivePostingKey(),
          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () {
                    onLoginTapped(appData);
                  },
                  child: const Text('Log in'),
                ),
        ],
      ),
    );
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            onPressed: () {
              showMessage(
                  'Concerned about security? Rest assured.\nYour posting key never leaves this app.\nIt is securely stored on your device ONLY.\nNo one, including us, will have it.');
            },
            icon: Icon(Icons.help),
          )
        ],
      ),
      body: _loginForm(data),
    );
  }
}
