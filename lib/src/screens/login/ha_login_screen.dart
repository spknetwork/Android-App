import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/action_response.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/new_home_screen.dart';
import 'package:acela/src/screens/login/sign_up_screen.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/graphql/gql_communicator.dart';
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

class _HiveAuthLoginScreenState extends State<HiveAuthLoginScreen> with TickerProviderStateMixin {
  static const platform = MethodChannel('blog.hive.auth/bridge');
  var usernameController = TextEditingController();
  late WebSocketChannel socket;
  String authKey = '';
  String hasIdToken = '';
  String proofOfPayload = '';
  String signedHash = '';
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
            var jsonData = {"account": usernameController.text, "uuid": uuid, "key": authKey, "host": Communicator.hiveAuthServer};
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
              hasIdToken = '';
            });
            break;
          case "challenge_ack":
            var messageData = asString(map, 'data');
            decryptChallenge(widget.appData, messageData);
            break;
          case "challenge_nack":
            showError("You denied signing the auth for authentication");
            setState(() {
              proofOfPayload = '';
              signedHash = '';
              qrCode = null;
              timer = 0;
              loadingQR = false;
            });
            break;
          case "sign_ack":
            performSignInWithHAS(true);
            break;
          case "sign_nack":
            showError("3Speak does not have posting authority to your account. You can not publish videos");
            performSignInWithHAS(false);
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
    if (usernameController.text.isEmpty) {
      showError('Please enter hive username');
      return;
    }
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
        label: const Text('Hive Private Posting Key'),
        hintText: 'Copy & paste Private posting key here',
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
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white),
                        child: QrImageView(
                          data: qr,
                          size: 200,
                          gapless: true,
                        ),
                      ),
                      onTap: () {
                        var url = Uri.parse(qr);
                        launchUrl(url);
                      },
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
                    const Text('Authorize this request with "Keychain for Hive" app.'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        var url = Uri.parse(qr);
                        launchUrl(url);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: Image.asset('assets/hive-keychain-image.png', width: 220),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text('Login with Posting Key'),
                    ),
                    const SizedBox(height: 10),
                    const Text('- OR -'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        const screen = SignUpScreen();
                        var route = MaterialPageRoute(builder: (c) => screen);
                        Navigator.of(context).push(route);
                      },
                      child: Text('Sign up'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    ),
                  ],
                ),
              )
            : _showQRCodeAndKeychainButton(qrCode!);
  }

  void onLoginTapped(HiveUserData appData) async {
    if (usernameController.text.isEmpty) {
      showError('Please enter hive username');
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var platform = MethodChannel('com.example.acela/auth');
      final String response = await platform.invokeMethod('validateHiveKey', {
        'username': usernameController.text,
        'postingKey': postingKey,
      });
      var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
      if (bridgeResponse.valid) {
        final String doWeHave = await MethodChannel("blog.hive.auth/bridge").invokeMethod(
          'doWeHavePostingAuth',
          {
            'username': usernameController.text,
          },
        );
        var doWeHaveResponse = LoginBridgeResponse.fromJsonString(doWeHave);
        if (doWeHaveResponse.valid) {
          var authority = doWeHaveResponse.data != null && doWeHaveResponse.data != "true";
          if (authority) {
            showError("3Speak does not have posting authority to your account. You can not publish videos");
          }
          await storage.write(key: 'postingAuth', value: "${authority ? 'true' : 'false'}");
          String proofPayload = json.encode({'account': usernameController.text, 'ts': DateTime.now().toIso8601String()});
          const platform = MethodChannel('com.example.acela/auth');
          final String result = await platform.invokeMethod('getProofOfPayload', {
            'username': usernameController.text,
            'postingKey': postingKey,
            'proof': proofPayload,
          });
          LoginBridgeResponse actionResponse = LoginBridgeResponse.fromJsonString(result);
          if (actionResponse.valid && actionResponse.error == '' && actionResponse.data != null && actionResponse.data!.isNotEmpty) {
            var loginApiResponse = await Communicator().login(usernameController.text, proofPayload, actionResponse.data!);
            if (loginApiResponse.valid) {
              debugPrint("Successful login");
              String resolution = await storage.read(key: 'resolution') ?? '480p';
              String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
              String union = await storage.read(key: 'union') ?? GQLCommunicator.defaultGQLServer;
              String? lang = await storage.read(key: 'lang');
              await storage.write(key: 'username', value: usernameController.text);
              await storage.write(key: 'postingKey', value: postingKey);
              await storage.write(key: 'accessToken', value: loginApiResponse.data);
              await storage.delete(key: 'hasId');
              await storage.delete(key: 'hasExpiry');
              await storage.delete(key: 'hasAuthKey');
              await storage.delete(key: 'cookie');
              var data = HiveUserData(
                username: usernameController.text,
                postingKey: postingKey,
                keychainData: null,
                accessToken: loginApiResponse.data,
                resolution: resolution,
                rpc: rpc,
                union: union,
                loaded: true,
                language: lang,
              );
              server.updateHiveUserData(data);
              Navigator.of(context).pop();
              var screen = GQLFeedScreen(
                appData: data,
                username: usernameController.text,
              );
              var route = MaterialPageRoute(builder: (c) => screen);
              Navigator.of(context).pushReplacement(route);
              showMessage('You have successfully logged in as - ${usernameController.text}');
              setState(() {
                isLoading = false;
              });
            } else {
              showError(loginApiResponse.error);
              setState(() {
                isLoading = false;
              });
            }
          } else {
            showError(actionResponse.error);
            setState(() {
              isLoading = false;
            });
          }
        } else {
          showError(doWeHaveResponse.error);
          setState(() {
            isLoading = false;
          });
        }
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
      log(e.toString());
      if (e == 'No 3Speak Account found with name - ${usernameController.text}') {
        await storage.delete(key: 'username');
        await storage.delete(key: 'postingKey');
        await storage.delete(key: 'hasId');
        await storage.delete(key: 'hasExpiry');
        await storage.delete(key: 'hasAuthKey');
        await storage.delete(key: 'cookie');
        var data = HiveUserData(
          username: null,
          postingKey: null,
          keychainData: null,
          accessToken: null,
          resolution: '480p',
          rpc: 'api.hive.blog',
          union: GQLCommunicator.defaultGQLServer,
          loaded: true,
          language: null,
        );
        server.updateHiveUserData(data);
      }
      showError('Error occurred - ${e.toString()}');
    }
  }

  @override
  void dispose() {
    super.dispose();
    socket.sink.close();
  }

  void decryptChallenge(HiveUserData data, String encryptedData) async {
    final String response = await platform.invokeMethod('getDecryptedChallenge', {
      'username': usernameController.text,
      'authKey': authKey,
      'data': encryptedData,
    });
    var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
    if (bridgeResponse.valid && bridgeResponse.data != null && bridgeResponse.data!.isNotEmpty) {
      setState(() {
        signedHash = bridgeResponse.data!;
      });
      final String postingAuthResponse = await platform.invokeMethod('getPostingAuthOps', {
        'username': usernameController.text,
        'authKey': authKey,
      });
      var postingAuthBridgeResponse = LoginBridgeResponse.fromJsonString(postingAuthResponse);
      if (postingAuthBridgeResponse.valid) {
        if (postingAuthBridgeResponse.data != null && postingAuthBridgeResponse.data!.isNotEmpty) {
          // get posting authority here.
          var socketData = {
            "cmd": "sign_req",
            "account": usernameController.text,
            "token": hasIdToken,
            "data": bridgeResponse.data!,
          };
          var jsonEncodedData = json.encode(socketData);
          socket.sink.add(jsonEncodedData);
        } else {
          performSignInWithHAS(true);
        }
      } else {
        showMessage('Error getting posting authority details. Please try again.');
      }
    } else {
      showMessage('Something went wrong - ${bridgeResponse.error}. Please go back & try again.');
    }
  }

  void performSignInWithHAS(bool authority) async {
    debugPrint("Signed proof is $signedHash");
    debugPrint("Proof of Payload is $proofOfPayload");
    debugPrint("Username is ${usernameController.text}");
    var loginApiResponse = await Communicator().login(usernameController.text, proofOfPayload, signedHash);
    String resolution = await storage.read(key: 'resolution') ?? '480p';
    String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
    String union = await storage.read(key: 'union') ?? GQLCommunicator.defaultGQLServer;
    String? lang = await storage.read(key: 'lang');
    await storage.write(key: 'username', value: usernameController.text);
    await storage.delete(key: 'postingKey');
    await storage.write(key: 'accessToken', value: loginApiResponse.data);
    await storage.write(key: 'postingAuth', value: "${authority ? 'true' : 'false'}");
    var data = HiveUserData(
      username: usernameController.text,
      postingKey: null,
      keychainData: null,
      accessToken: loginApiResponse.data,
      resolution: resolution,
      rpc: rpc,
      union: union,
      loaded: true,
      language: lang,
    );
    server.updateHiveUserData(data);
    Navigator.of(context).pop();
    var screen = GQLFeedScreen(
      appData: data,
      username: usernameController.text,
    );
    var route = MaterialPageRoute(builder: (c) => screen);
    Navigator.of(context).pushReplacement(route);
    showMessage('You have successfully logged in as - ${usernameController.text}');
    setState(() {
      isLoading = false;
    });
  }

  void decryptData(HiveUserData data, String encryptedData) async {
    final String response = await platform.invokeMethod('getDecryptedHASToken', {
      'username': usernameController.text,
      'authKey': authKey,
      'data': encryptedData,
    });
    var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
    if (bridgeResponse.valid && bridgeResponse.data != null && bridgeResponse.data!.isNotEmpty) {
      var tokenData = bridgeResponse.data!.split(",");
      if (tokenData.isEmpty || tokenData.length != 2) {
        showMessage('Did not find token & expiry details from HiveAuth. Please go back & try again.');
      } else {
        const storage = FlutterSecureStorage();
        await storage.write(key: 'username', value: usernameController.text);
        await storage.delete(key: 'postingKey');
        await storage.delete(key: 'cookie');
        await storage.write(key: 'hasId', value: tokenData[0]);
        await storage.write(key: 'hasExpiry', value: tokenData[1]);
        await storage.write(key: 'hasAuthKey', value: authKey);
        var newData = HiveUserData(
          username: usernameController.text,
          postingKey: null,
          keychainData: HiveKeychainData(
            hasAuthKey: authKey,
            hasExpiry: tokenData[1],
            hasId: tokenData[0],
          ),
          accessToken: null,
          resolution: data.resolution,
          rpc: data.rpc,
          union: data.union,
          loaded: true,
          language: data.language,
        );
        server.updateHiveUserData(newData);
        showMessage('You have successfully logged in with Hive Auth with user - ${usernameController.text}');
        final String eChallengeResponse = await platform.invokeMethod('getEncryptedChallenge', {
          'username': usernameController.text,
          'authKey': authKey,
        });
        var eChallengeResponseData = json.decode(eChallengeResponse)['data'] as String;
        var eData = eChallengeResponseData.split("|")[0];
        setState(() {
          hasIdToken = tokenData[0];
          proofOfPayload = eChallengeResponseData.split("|")[1];
        });
        var socketData = {
          "cmd": "challenge_req",
          "account": usernameController.text,
          "token": tokenData[0],
          "data": eData,
        };
        var jsonEncodedData = json.encode(socketData);
        socket.sink.add(jsonEncodedData);
        // Navigator.of(context).pop();
        // var screen = GQLFeedScreen(
        //   appData: newData,
        //   username: usernameController.text,
        // );
        // var route = MaterialPageRoute(builder: (c) => screen);
        // Navigator.of(context).pushReplacement(route);
      }
    } else {
      showMessage('Something went wrong - ${bridgeResponse.error}. Please go back & try again.');
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
