import 'package:acela/src/screens/home_screen/home_screen.dart';
import 'package:acela/src/screens/leaderboard_screen/leaderboard_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_screen.dart';
import 'package:acela/src/screens/video_details_screen/video_details_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import 'src/bloc/server.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  bool isDarkMode = true;

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
        });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acela - 3Speak App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == VideoDetailsScreen.routeName) {
          final args = settings.arguments as VideoDetailsScreenArguments;
          return MaterialPageRoute(builder: (context) {
            return VideoDetailsScreen(
                vm: VideoDetailsViewModel(item: args.item));
          });
        } else if (settings.name == "/") {
          return MaterialPageRoute(builder: (context) {
            return HomeScreen(
              path: "${server.domain}/apiv2/feeds/home",
              showDrawer: true,
              title: 'Home',
              isDarkMode: isDarkMode,
              switchDarkMode: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            );
          });
        } else if (settings.name == "/trending") {
          return MaterialPageRoute(builder: (context) {
            return HomeScreen(
                path: "${server.domain}/apiv2/feeds/trending",
                showDrawer: false,
                title: 'Trending Content',
                isDarkMode: isDarkMode,
                switchDarkMode: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                });
          });
        } else if (settings.name == "/new") {
          return MaterialPageRoute(builder: (context) {
            return HomeScreen(
                path: "${server.domain}/apiv2/feeds/new",
                showDrawer: false,
                title: 'New Content',
                isDarkMode: isDarkMode,
                switchDarkMode: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                });
          });
        } else if (settings.name == "/leaderboard") {
          return MaterialPageRoute(builder: (context) {
            return const LeaderboardScreen();
          });
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}
