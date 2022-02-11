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

  MaterialPageRoute configuredHomeWidget(String title, String path, bool showDrawer) {
    return MaterialPageRoute(builder: (context) {
      return HomeScreen(
        path: path, //"${server.domain}/apiv2/feeds/home",
        showDrawer: showDrawer,
        title: title,
        isDarkMode: isDarkMode,
        switchDarkMode: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      );
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
        if (settings.name?.contains("/watch?") == true) {
          return MaterialPageRoute(builder: (context) {
            return VideoDetailsScreen(
                vm: VideoDetailsViewModel.from(settings.name!));
          });
        } else if (settings.name == "/") {
          return configuredHomeWidget(
              'Home', "${server.domain}/apiv2/feeds/home", true);
        } else if (settings.name == "/trending") {
          return configuredHomeWidget(
              'Trending Content', "${server.domain}/apiv2/feeds/trending", false);
        } else if (settings.name == "/new") {
          return configuredHomeWidget(
              'New Content', "${server.domain}/apiv2/feeds/new", false);
        } else if (settings.name == "/firstUploads") {
          return configuredHomeWidget(
              'First Uploads', "${server.domain}/apiv2/feeds/firstUploads", false);
        } else if (settings.name?.contains("/userChannel/") == true) {
          var last = settings.name?.split("/userChannel/").last ?? "sagarkothari88";
          return configuredHomeWidget(
              last, "${server.domain}/apiv2/feeds/@$last", false);
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
