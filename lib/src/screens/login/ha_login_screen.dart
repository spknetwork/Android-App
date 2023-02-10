import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/crypto_manager.dart';
import 'package:acela/src/utils/safe_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HiveAuthLoginScreen extends StatefulWidget {
  const HiveAuthLoginScreen({
    Key? key,
    required this.appData,
  }) : super(key: key);
  final HiveUserData appData;

  @override
  State<HiveAuthLoginScreen> createState() => _HiveAuthLoginScreenState();
}

class _HiveAuthLoginScreenState extends State<HiveAuthLoginScreen>
    with TickerProviderStateMixin {
  static const platform = MethodChannel('blog.hive.auth/bridge');
  var usernameController = TextEditingController();
  late WebSocketChannel socket;
  String authKey = '';
  String username = '';
  String? qrCode;
  var loadingQR = false;
  var timer = 0;
  var timeoutValue = 0;
  Timer? ticker;
  var didTapKeychainButton = false;

  var isLoading = false;
  var postingKey = '';
  static const storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    socket = WebSocketChannel.connect(
      Uri.parse(Communicator.hiveAuthServer),
    );
    socket.stream.listen((message) {
      var map = json.decode(message) as Map<String, dynamic>;
      var cmd = asString(map, 'cmd');
      if (cmd.isNotEmpty) {
        switch (cmd) {
          case "connected":
            setState(() {
              timeoutValue = asInt(map, 'timeout');
            });
            break;
          case "auth_wait":
            var uuid = asString(map, 'uuid');
            var jsonData = {
              "account": usernameController.text,
              "uuid": uuid,
              "key": authKey,
              "host": Communicator.hiveAuthServer
            };
            var jsonString = json.encode(jsonData);
            var utf8Data = utf8.encode(jsonString);
            var qr = base64.encode(utf8Data);
            qr = "has://auth_req/$qr";
            setState(() {
              qrCode = qr;
              if (didTapKeychainButton) {
                var uri = Uri.tryParse(qr);
                if (uri != null) {
                  launchUrl(uri);
                }
              }
              timer = timeoutValue;
              ticker = Timer.periodic(Duration(seconds: 1), (tickrr) {
                if (timer == 0) {
                  setState(() {
                    tickrr.cancel();
                    qrCode = null;
                  });
                } else {
                  setState(() {
                    timer--;
                  });
                }
              });
              loadingQR = false;
            });
            break;
          case "auth_ack":
            var messageData = asString(map, 'data');
            decryptData(widget.appData, messageData);
            break;
          case "auth_nack":
            showError("Auth was not acknowledged");
            setState(() {
              qrCode = null;
              timer = 0;
              loadingQR = false;
            });
            break;
          default:
            log('Default case here');
        }
      }
    });
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _hiveUserName() {
    return TextField(
      decoration: InputDecoration(
        icon: const Icon(Icons.alternate_email_outlined),
        label: const Text('Hive Username'),
        hintText: 'Enter Hive username here',
      ),
      autocorrect: false,
      controller: usernameController,
    );
  }

  void _hasButtonTapped(bool keychainTapped) async {
    if (usernameController.text.isEmpty) return;
    setState(() {
      loadingQR = true;
    });
    final String response = await platform.invokeMethod('getRedirectUriData', {
      'username': usernameController.text,
    });
    var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
    if (bridgeResponse.data != null) {
      var data = json.decode(bridgeResponse.data!) as Map<String, dynamic>;
      var dataForSocket = asString(data, 'data');
      var key = asString(data, 'authKey');
      var socketData = {
        "cmd": "auth_req",
        "account": usernameController.text,
        "data": dataForSocket,
      };
      var jsonEncodedData = json.encode(socketData);
      socket.sink.add(jsonEncodedData);
      setState(() {
        didTapKeychainButton = keychainTapped;
        authKey = key;
        username = usernameController.text;
      });
    }
  }

  Widget _hasButton(HiveUserData data) {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            _hasButtonTapped(true);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Image.asset('assets/hive-keychain-image.png', width: 120),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            _hasButtonTapped(false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: Image.asset('assets/hive_auth_button.png', width: 120),
        ),
        const Spacer(),
      ],
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

  Widget _showQRCodeAndKeychainButton(String qr) {
    return Center(
      child: Column(
        children: [
          didTapKeychainButton
              ? Container()
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    Image.asset('assets/hive_auth_button.png'),
                    const SizedBox(height: 10),
                    Text('Scan QR Code'),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: QrImage(
                        data: qr,
                        size: 200.0,
                        gapless: true,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: timer.toDouble() / timeoutValue.toDouble(),
                        semanticsLabel: 'Timeout Timer for HiveAuth QR',
                      ),
                    ),
                  ],
                ),
          didTapKeychainButton
              ? Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                        'Authorize this request with "Keychain for Hive" app.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        var url = Uri.parse(qr);
                        launchUrl(url);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: Image.asset('assets/hive-keychain-image.png',
                          width: 220),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: timer.toDouble() / timeoutValue.toDouble(),
                        semanticsLabel: 'Timeout Timer for HiveAuth QR',
                      ),
                    ),
                  ],
                )
              : Container()
        ],
      ),
    );
  }

  Widget _loginForm(HiveUserData appData) {
    return loadingQR || isLoading
        ? const Center(child: CircularProgressIndicator())
        : qrCode == null
            ? Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    _hiveUserName(),
                    const SizedBox(height: 10),
                    _hasButton(appData),
                    const SizedBox(height: 10),
                    const Text('- OR -'),
                    const SizedBox(height: 10),
                    _hivePostingKey(),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        onLoginTapped(appData);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black),
                      child: const Text('Login with Posting Key'),
                    ),
                  ],
                ),
              )
            : _showQRCodeAndKeychainButton(qrCode!);
  }

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

  @override
  void dispose() {
    super.dispose();
    socket.sink.close();
  }

  void decryptData(HiveUserData data, String encryptedData) async {
    final String response =
        await platform.invokeMethod('getDecryptedHASToken', {
      'username': username,
      'authKey': authKey,
      'data': encryptedData,
    });
    var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
    if (bridgeResponse.valid &&
        bridgeResponse.data != null &&
        bridgeResponse.data!.isNotEmpty) {
      var tokenData = bridgeResponse.data!.split(",");
      if (tokenData.isEmpty || tokenData.length != 2) {
        showMessage(
            'Did not find token & expiry details from HiveAuth. Please go back & try again.');
      } else {
        const storage = FlutterSecureStorage();
        await storage.write(key: 'username', value: username);
        await storage.delete(key: 'postingKey');
        await storage.delete(key: 'cookie');
        await storage.write(key: 'hasId', value: tokenData[0]);
        await storage.write(key: 'hasExpiry', value: tokenData[1]);
        await storage.write(key: 'hasAuthKey', value: authKey);
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: null,
            keychainData: HiveKeychainData(
              hasAuthKey: authKey,
              hasExpiry: tokenData[1],
              hasId: tokenData[0],
            ),
            cookie: null,
            resolution: data.resolution,
            rpc: data.rpc,
          ),
        );
        showMessage(
            'You have successfully logged in with Hive Auth with user - $username');
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } else {
      showMessage(
          'Something went wrong - ${bridgeResponse.error}. Please go back & try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with your account'),
      ),
      body: _loginForm(data),
    );
  }
}
