import 'dart:developer';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/models/video_details_model/video_details.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/widgets/custom_circle_avatar.dart';
import 'package:acela/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  Future<List<VideoDetails>>? loadVideos;
  Future<void>? loadOperations;
  var isLoading = false;

  void logout() async {
    // Create storage
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'username');
    await storage.delete(key: 'postingKey');
    server.updateHiveUserData(null);
    Navigator.of(context).pop();
  }

  void loadVideoInfo(HiveUserData user, String videoId) async {
    setState(() {
      isLoading = true;
    });
    try {
      var result = await Communicator().loadOperations(user, videoId);
      var platform = MethodChannel('com.example.acela/auth');
      final String response = await platform.invokeMethod('postVideo', {
        'data': result,
        'postingKey': user.postingKey,
      });
      var bridgeResponse = LoginBridgeResponse.fromJsonString(response);
      if (bridgeResponse.valid == true) {
        await Communicator().updatePublishState(user, videoId);
        setState(() {
          loadVideos = Communicator().loadVideos(user);
        });
      } else {
        showError('Error occurred: ${bridgeResponse.error}');
      }
      log('Result from android platform is \n$response');
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

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<HiveUserData?>(context);
    if (user != null && loadVideos == null) {
      setState(() {
        loadVideos = Communicator().loadVideos(user);
      });
    }
    var username = user?.username ?? 'Unknown';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CustomCircleAvatar(
              height: 36,
              width: 36,
              url: 'https://images.hive.blog/u/$username/avatar',
            ),
            const SizedBox(width: 5),
            Text(user?.username ?? 'Unknown'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout();
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Container(
        child: user == null
            ? Center(child: const Text('Nothing'))
            : isLoading
                ? Center(child: const CircularProgressIndicator())
                : FutureBuilder(
                    future: loadVideos,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: const Text('Something went wrong'));
                      } else if (snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.done) {
                        List<VideoDetails> items =
                            snapshot.data! as List<VideoDetails>;
                        return ListView.separated(
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Image.network(
                                items[index].thumbUrl,
                              ),
                              title: Text(items[index].title),
                              subtitle: Text(items[index].description),
                              trailing: items[index].status == 'published'
                                  ? Icon(Icons.check, color: Colors.green)
                                  : items[index].status == 'publish_manual'
                                      ? IconButton(
                                          onPressed: () {
                                            loadVideoInfo(
                                                user, items[index].id);
                                          },
                                          icon: Icon(
                                            Icons.rocket_launch,
                                            color: Colors.green,
                                          ),
                                        )
                                      : Icon(
                                          Icons.hourglass_top,
                                          color: Colors.blue,
                                        ),
                              onTap: () {},
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: items.length,
                        );
                      } else {
                        return const LoadingScreen();
                      }
                    },
                  ),
      ),
    );
  }
}
/*
successful response from platform after posting it to hive
text to find => "signatures":["
{"type":"postVideo","valid":true,"error":"{\"id\":\"2412d5c4fab06633dea4e2741bcbfab9b0607312\",\"ref_block_num\":56580,\"ref_block_prefix\":1839428099,\"expiration\":\"2022-06-26T04:16:33\",\"operations\":[[\"comment\",{\"parent_author\":\"\",\"parent_permlink\":\"hive-181335\",\"author\":\"shaktimaaan\",\"permlink\":\"jhfyjgke\",\"title\":\"This is a test video from Sagar\",\"body\":\"<center><br/><br/>[![](https://ipfs-3speak.b-cdn.net/ipfs/bafybeifncqfcpxuf2vcgn4n7kl3ilhhoe5p5faubl7gyajvh4x7ldbmxze/)](https://3speak.tv/watch?v=shaktimaaan/jhfyjgke)<br/><br/>[Watch on 3Speak](https://3speak.tv/watch?v=shaktimaaan/jhfyjgke)<br/><br/></center><br/><br/>---<br/><br/>at 8 PM in the evening.<br/><br/>---<br/><br/>[3Speak](https://3speak.tv/watch?v=shaktimaaan/jhfyjgke)<br/>\",\"json_metadata\":\"{\\\"tags\\\":[\\\"sagar\\\",\\\"india\\\",\\\"threespeak\\\"],\\\"app\\\":\\\"3speak/0.3.0\\\",\\\"type\\\":\\\"3speak/video\\\",\\\"image\\\":[\\\"https://ipfs-3speak.b-cdn.net/ipfs/bafybeifncqfcpxuf2vcgn4n7kl3ilhhoe5p5faubl7gyajvh4x7ldbmxze\\\"],\\\"video\\\":{\\\"info\\\":{\\\"platform\\\":\\\"3speak\\\",\\\"title\\\":\\\"This is a test video from Sagar\\\",\\\"author\\\":\\\"shaktimaaan\\\",\\\"permlink\\\":\\\"jhfyjgke\\\",\\\"duration\\\":0,\\\"filesize\\\":35853229,\\\"file\\\":\\\"ipfs://bafybeibqr3sg2jm6oohykzfbrr24l4lqx7kiynuhiibp7gyvyznn65hvom\\\",\\\"lang\\\":\\\"en\\\",\\\"firstUpload\\\":false,\\\"ipfs\\\":null,\\\"ipfsThumbnail\\\":null,\\\"video_v2\\\":\\\"ipfs://QmaC1dQuAHNtuxNKbARbMhTA2x4PQntMqrQpmZLT1MdzJ4/manifest.m3u8\\\",\\\"sourceMap\\\":[{\\\"type\\\":\\\"video\\\",\\\"url\\\":\\\"ipfs://QmaC1dQuAHNtuxNKbARbMhTA2x4PQntMqrQpmZLT1MdzJ4/manifest.m3u8\\\",\\\"format\\\":\\\"m3u8\\\"},{\\\"type\\\":\\\"thumbnail\\\",\\\"url\\\":\\\"ipfs://bafybeifncqfcpxuf2vcgn4n7kl3ilhhoe5p5faubl7gyajvh4x7ldbmxze\\\"}]},\\\"content\\\":{\\\"description\\\":\\\"at 8 PM in the evening.\\\",\\\"tags\\\":[\\\"sagar\\\",\\\"india\\\",\\\"threespeak\\\"]}}}\"}],[\"comment_options\",{\"author\":\"shaktimaaan\",\"permlink\":\"jhfyjgke\",\"max_accepted_payout\":\"100000.000 SBD\",\"percent_hbd\":10000,\"allow_votes\":true,\"allow_curation_rewards\":true,\"extensions\":[[0,{\"beneficiaries\":[{\"account\":\"sagarkothari88\",\"weight\":200},{\"account\":\"spk.beneficiary\",\"weight\":900},{\"account\":\"threespeakleader\",\"weight\":100}]}]]}],[\"custom_json\",{\"required_auths\":[],\"required_posting_auths\":[\"shaktimaaan\"],\"id\":\"3speak-publish\",\"json\":\"{\\\"author\\\":\\\"shaktimaaan\\\",\\\"permlink\\\":\\\"jhfyjgke\\\",\\\"category\\\":\\\"general\\\",\\\"language\\\":\\\"en\\\",\\\"duration\\\":0,\\\"title\\\":\\\"This is a test video from Sagar\\\"}\"}]],\"extensions\":[],\"signatures\":[\"1f289958c1ebf58950727c0df7cc546302949e42ae6924482d64d14fd8780035f2328a4c8d357e1bb362971fde8c2fd73646dbd702e724e0f750d46fc96924a8b6\"]}"}
 */
