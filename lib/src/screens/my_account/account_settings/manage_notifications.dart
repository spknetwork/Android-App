import 'package:acela/src/models/my_account/my_devices.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/loading_screen.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageNotificationsScreen extends StatefulWidget {
  const ManageNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<ManageNotificationsScreen> createState() =>
      _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  Future<List<MyDevicesDataItem>>? getDevices;
  var isDeletingOrSending = false;

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteToken(String token, HiveUserData user) async {
    setState(() {
      isDeletingOrSending = true;
    });
    try {
      await Communicator().deleteToken(user, token);
    } catch (e) {
      showError("Something went wrong\n${e.toString()}");
    } finally {
      setState(() {
        isDeletingOrSending = false;
        getDevices = null;
      });
    }
  }

  Widget _deviceList(List<MyDevicesDataItem> list, HiveUserData user) {
    if (list.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 220),
          child: Text(
            "No devices are added for notifications.\n\nTap on Plus, to get notified when your video finishes the processing and ready for publishing.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.separated(
        itemBuilder: (c, i) {
          var tokenSuffix = list[i].token.substring(list[i].token.length - 10);
          return ListTile(
            leading: const Icon(Icons.phone_android),
            subtitle: Text("Push Token ending with $tokenSuffix"),
            trailing: IconButton(
              onPressed: () {
                deleteToken(list[i].token, user);
              },
              icon: const Icon(Icons.delete),
            ),
            title: Text(list[i].deviceName),
          );
        },
        separatorBuilder: (c, i) => Divider(),
        itemCount: list.length,
      ),
    );
  }

  Widget _futureForDevices(HiveUserData user) {
    return FutureBuilder(
      future: getDevices,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: const Text('Something went wrong'));
        } else if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return _deviceList(snapshot.data as List<MyDevicesDataItem>, user);
        } else {
          return const LoadingScreen(
            title: 'Loading Data',
            subtitle: 'Please wait',
          );
        }
      },
    );
  }

  // void registerForNotification(HiveUserData user) async {
  //   setState(() {
  //     isDeletingOrSending = true;
  //   });
  //   try {
  //     final fcmToken = await FirebaseMessaging.instance.getToken();
  //     var model = '';
  //     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //     if (Platform.isAndroid) {
  //       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //       print('Running on ${androidInfo.model}');
  //       model = androidInfo.model ?? 'Some Android Device';
  //     } else if (Platform.isIOS) {
  //       IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
  //       print('Running on ${iosDeviceInfo.model}');
  //       model = iosDeviceInfo.model ?? 'Some iOS Device';
  //     } else {
  //       model = 'Unknown Device type';
  //     }
  //     log('FCM Token is $fcmToken');
  //     await Communicator().addToken(user, fcmToken ?? "", model);
  //   } catch (e) {
  //     showError("Something went wrong\n${e.toString()}");
  //   } finally {
  //     setState(() {
  //       isDeletingOrSending = false;
  //       getDevices = null;
  //     });
  //   }
  // }

  void sendTestNotification(HiveUserData user) async {
    // testTokens
    setState(() {
      isDeletingOrSending = true;
    });
    try {
      await Communicator().testTokens(user);
    } catch (e) {
      showError("Something went wrong\n${e.toString()}");
    } finally {
      setState(() {
        isDeletingOrSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Manage Notifications'),
        ),
        body: SafeArea(
          child: const Text('Please re-login'),
        ),
      );
    }
    if (getDevices == null) {
      setState(() {
        getDevices = Communicator().loadDevices(user);
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Notifications'),
        actions: isDeletingOrSending
            ? []
            : [
                IconButton(
                    onPressed: () {
                      sendTestNotification(user);
                    },
                    icon: Icon(Icons.notifications))
              ],
      ),
      body: SafeArea(
        child: isDeletingOrSending
            ? const Center(child: CircularProgressIndicator())
            : _futureForDevices(user),
      ),
      // floatingActionButton: isDeletingOrSending
      //     ? null
      //     : FloatingActionButton(
      //         onPressed: () {
      //           registerForNotification(user);
      //         },
      //         child: const Icon(Icons.add),
      //       ),
    );
  }
}
