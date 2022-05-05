import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  // Create storage
  static const storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
    var username = user?.username ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(
        title: Text(user?.username ?? 'Unknown'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Center(
          child: Column(
            children: [
              Image.network(
                'https://images.hive.blog/u/$username/avatar',
                width: 100,
                height: 100,
              ),
              SizedBox(height: 10),
              Text(username, style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Log out'),
                onPressed: () async {
                  await storage.delete(key: 'username');
                  await storage.delete(key: 'postingKey');
                  server.updateHiveUserData(null);
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
