import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Sign up?'),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Spacer(),
                InkWell(
                  child: Text(
                    'Step 1. Click here 3Speak Sign up',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    var uri = Uri.parse('https://auth.3speak.tv/3/signupHive');
                    launchUrl(uri);
                  },
                ),
                const SizedBox(height: 35),
                Text(
                  'Step 2. Upload Human Verification Video from 3speak.tv website',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 35),
                InkWell(
                  child: Text(
                    'Step 3. Join Discord & ask for email for keys',
                    style: TextStyle(color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    var uri = Uri.parse(
                        'https://discord.gg/NSFS2VGj83?utm_source=3speak.tv.acela');
                    launchUrl(uri);
                  },
                ),
                const SizedBox(height: 35),
                Text(
                  'Step 4. Login with Posting key\nUse HiveKeychain App',
                  textAlign: TextAlign.center,
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
