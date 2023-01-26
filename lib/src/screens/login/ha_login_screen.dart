import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/safe_convert.dart';
import 'package:encryptor/encryptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class HiveAuthLoginScreen extends StatefulWidget {
  const HiveAuthLoginScreen({Key? key}) : super(key: key);

  @override
  State<HiveAuthLoginScreen> createState() => _HiveAuthLoginScreenState();
}

class _HiveAuthLoginScreenState extends State<HiveAuthLoginScreen> {
  var isLoading = false;
  var username = '';
  var appData = {
    "name": "3Speak Mobile iOS App",
    "description": "3Speak Mobile iOS App with HAS Integration",
  };
  var appKey = Uuid().v4();
  String? authUuid;
  String? authKey;
  String? token;
  String? expire;
  static const platform = MethodChannel('com.example.acela/auth');
  String? qrString;

  @override
  void initState() {
    super.initState();
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

  Widget _hasButton(HiveUserData data) {
    return ElevatedButton(
      onPressed: () async {
        if (username.isEmpty) return;
        setState(() {
          isLoading = true;
          authKey = Uuid().v4();
          if (authKey == null) return;
          var authData = {
            "app": appData,
            // "token": token,
            // "challenge": null,
          };
          var jsonString = json.encode(authData);
          var encrypted = Encryptor.encrypt(authKey!, jsonString);
          var payload = {
            "cmd": "auth_req",
            "account": username,
            "data": encrypted,
          };
          var payloadJsonString = json.encode(payload);
          data.socket?.sink.add(payloadJsonString);
        });
      },
      child: const Text('Log in with Hive Auth'),
    );
  }

  Widget _loginForm(HiveUserData appData) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          _hiveUserName(),
          SizedBox(height: 20),
          isLoading ? CircularProgressIndicator() : qrString == null ? _hasButton(appData) : QrImage(
            data: qrString!,
            version: QrVersions.auto,
            size: 200.0,
          ),
          StreamBuilder(
            stream: appData.socket?.stream,
            builder: (context, snapshot) {
              var data = snapshot.data as String?;
              if (snapshot.hasData && data != null && data.isNotEmpty == true) {
                var map = json.decode(data) as Map<String, dynamic>;
                var cmd = asString(map, 'cmd');
                if (cmd.isNotEmpty) {
                  switch (cmd) {
                    case "auth_wait":
                      var uuid = asString(map, 'uuid');
                      var qr = json.encode({
                        "account": username,
                        "uuid": uuid,
                        "key": authKey,
                        "host": Communicator.hiveAuthServer
                      });
                      setState(() {
                        this.qrString = qr;
                      });
                      break;
                    default:
                      log('Default case here');
                  }
                }
              }
              return Container();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login with Hive Auth'),
      ),
      body: _loginForm(data),
    );
  }
}
