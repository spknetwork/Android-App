import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  void onLoginTapped() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String result = await platform.invokeMethod('validate', {
        'username': username,
        'postingKey': postingKey,
      });
      var response = LoginBridgeResponse.fromJsonString(result);
      if (response.valid && response.error.isEmpty) {
        debugPrint("Successful login");
        await storage.write(key: 'username', value: username);
        await storage.write(key: 'postingKey', value: postingKey);
        await storage.delete(key: 'cookie');
        server.updateHiveUserData(
          HiveUserData(
            username: username,
            postingKey: postingKey,
            cookie: null,
          ),
        );
        Navigator.of(context).pop();
      } else {
        showError(response.error);
      }
      setState(() {
        isLoading = false;
      });
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

  Widget _loginForm() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
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
          ),
          SizedBox(height: 20),
          TextField(
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
          ),
          SizedBox(height: 20),
          isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: onLoginTapped,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            onPressed: () {
              showMessage(
                  'Concerned about security? Rest assured.\nYour posting key never leaves this app.\nIt is securely stored on your device ONLY.\nNo one, including us, will ever have it.');
            },
            icon: Icon(Icons.help),
          )
        ],
      ),
      body: _loginForm(),
    );
  }
}
