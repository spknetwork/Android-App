import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create storage
  static const storage = FlutterSecureStorage();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<HiveUserData?>.value(
      value: server.hiveUserData,
      initialData: null,
      child: StreamProvider<bool>.value(
        value: server.theme,
        initialData: true,
        child: const AcelaApp(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    String? username = await storage.read(key: 'username');
    String? postingKey = await storage.read(key: 'postingKey');
    if (username != null &&
        postingKey != null &&
        username.isNotEmpty &&
        postingKey.isNotEmpty) {
      server.updateHiveUserData(
        HiveUserData(
          username: username,
          postingKey: postingKey,
        ),
      );
    }
  }
}

class AcelaApp extends StatelessWidget {
  const AcelaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDarkMode = Provider.of<bool>(context);
    return MaterialApp(
      title: 'Acela - 3Speak App',
      home: HomeScreen.home(),
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
    );
  }
}
