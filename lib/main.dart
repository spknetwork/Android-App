import 'dart:developer';
import 'package:acela/src/screens/communities_screen/communities_screen.dart';
import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final Future<FirebaseApp> _fbApp =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var _index = 0;

  Widget futureBuilder(Widget withWidget) {
    return FutureBuilder(
      future: _fbApp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Firebase not initialized');
        } else if (snapshot.hasData) {
          return withWidget;
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acela - 3Speak App',
      home: SafeArea(
        child: Scaffold(
          body: IndexedStack(
            children: [
              HomeScreen.home(),
              HomeScreen.trending(),
              HomeScreen.newContent(),
              HomeScreen.firstUploads(),
              const CommunitiesScreen(),
            ],
            index: _index,
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) {
              log("User tapped on index $index");
              setState(() {
                _index = index;
              });
            },
            currentIndex: _index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
                backgroundColor: Colors.black87,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department),
                label: 'Trending',
                // backgroundColor: Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_arrow),
                label: 'New',
                // backgroundColor: Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_emotions_outlined),
                label: 'First Uploads',
                // backgroundColor: Theme.of(context).primaryColor,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_sharp),
                label: 'Communities',
                // backgroundColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
