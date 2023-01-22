import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/screens/home_screen/home_screen.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });

  String? title;
  String? body;
}

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
  late final Future<void> _futureToLoadData;

  // late final FirebaseMessaging _messaging;
  // Create storage

  Widget futureBuilder(Widget withWidget) {
    return FutureBuilder(
      future: _futureToLoadData,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Firebase not initialized');
        } else if (snapshot.connectionState == ConnectionState.done) {
          return withWidget;
        } else {
          return MaterialApp(
            title: 'Acela',
            home: Scaffold(
              appBar: AppBar(title: const Text('Acela')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: futureBuilder(
        StreamProvider<HiveUserData>.value(
          value: server.hiveUserData,
          initialData: HiveUserData(
            resolution: '480p',
            keychainData: null,
            cookie: null,
            postingKey: null,
            username: null,
            rpc: 'api.hive.blog',
          ),
          child: StreamProvider<bool>.value(
            value: server.theme,
            initialData: true,
            child: const AcelaApp(),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _futureToLoadData = loadData();
  }

  // Future<void> handlingNotification() async {
  //   try {
  //     // 3. On iOS, this helps to take the user permissions
  //     NotificationSettings settings = await _messaging.requestPermission(
  //       alert: true,
  //       badge: false,
  //       provisional: false,
  //       sound: true,
  //     );
  //     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //       print('User granted permission');
  //       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //         // Parse the message received
  //         PushNotification notification = PushNotification(
  //           title: message.notification?.title,
  //           body: message.notification?.body,
  //         );
  //
  //         setState(() {
  //           showSimpleNotification(
  //             Text(notification.title ?? "No title for notification"),
  //             // leading: NotificationBadge(totalNotifications: _totalNotifications),
  //             subtitle: Text(notification.body ??
  //                 "No text provided for info of notification"),
  //             background: Colors.cyan.shade700,
  //             duration: Duration(seconds: 2),
  //           );
  //         });
  //       });
  //     } else {
  //       print('User declined or has not accepted permission');
  //     }
  //   } catch (e) {
  //     print("Something went wrong in setting up fcm ${e.toString()}");
  //   }
  // }

  Future<void> loadData() async {
    // setup firebase
    // await Firebase.initializeApp(
    //     options: DefaultFirebaseOptions.currentPlatform);
    // _messaging = FirebaseMessaging.instance;
    // handle notifications
    // await handlingNotification();
    // load storage
    const storage = FlutterSecureStorage();
    String? username = await storage.read(key: 'username');
    String? postingKey = await storage.read(key: 'postingKey');
    String? cookie = await storage.read(key: 'cookie');
    String? hasId = await storage.read(key: 'hasId');
    String? hasExpiry = await storage.read(key: 'hasExpiry');
    String? hasAuthKey = await storage.read(key: 'hasAuthKey');
    String resolution = await storage.read(key: 'resolution') ?? '480p';
    String rpc = await storage.read(key: 'rpc') ?? 'api.hive.blog';
    server.updateHiveUserData(
      HiveUserData(
        username: username,
        postingKey: postingKey,
        keychainData: hasId != null &&
                hasId.isNotEmpty &&
                hasExpiry != null &&
                hasExpiry.isNotEmpty &&
                hasAuthKey != null &&
                hasAuthKey.isNotEmpty
            ? HiveKeychainData(
                hasAuthKey: hasAuthKey,
                hasExpiry: hasExpiry,
                hasId: hasId,
              )
            : null,
        cookie: cookie,
        resolution: resolution,
        rpc: rpc,
      ),
    );
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
