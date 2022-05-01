import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var isLoading = false;
  static const platform = MethodChannel('com.example.acela/auth');
  var isValid = 'not validated yet';

  void onLoginTapped() async {
    setState(() {
      isLoading = true;
    });
    try {
      final String result = await platform.invokeMethod(
        'validate',
        {
          'username': 'sagarkothari88',
          'postingKey': '',
        },
      );
      setState(() {
        isLoading = false;
        isValid = result;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isValid = 'failed';
      });
    }
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text('is valid key - $isValid'),
              ],
            ),
      floatingActionButton: isLoading
          ? null
          : FloatingActionButton(
              onPressed: onLoginTapped,
              child: Icon(Icons.login),
            ),
    );
  }
}
