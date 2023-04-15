import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:acela/src/models/hive_post_info/hive_post_info.dart';
import 'package:acela/src/models/login/login_bridge_response.dart';
import 'package:acela/src/models/user_stream/hive_user_stream.dart';
import 'package:acela/src/utils/communicator.dart';
import 'package:acela/src/utils/safe_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HiveUpvoteDialog extends StatefulWidget {
  const HiveUpvoteDialog({
    Key? key,
    required this.username,
    required this.author,
    required this.permlink,
    required this.hasKey,
    required this.hasAuthKey,
    required this.activeVotes,
    required this.onClose,
    required this.onDone,
  }) : super(key: key);
  final String username;
  final String author;
  final String permlink;
  final String hasKey;
  final String hasAuthKey;
  final Function onDone;
  final Function onClose;
  final List<ActiveVotesItem> activeVotes;

  @override
  State<HiveUpvoteDialog> createState() => _HiveUpvoteDialogState();
}

class _HiveUpvoteDialogState extends State<HiveUpvoteDialog> {
  var isUpVoting = false;
  var sliderValue = 0.1;
  late WebSocketChannel socket;
  var socketClosed = true;
  String? qrCode;
  var timer = 0;
  var timeoutValue = 0;
  Timer? ticker;
  var loadingQR = false;

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text('Message: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    if (widget.activeVotes
            .where((element) => element.voter == widget.username)
            .length >
        0) {
      // No need of socket because user has already voted.
    } else {
      socket = WebSocketChannel.connect(
        Uri.parse(Communicator.hiveAuthServer),
      );
      socket.stream.listen((message) {
        var map = json.decode(message) as Map<String, dynamic>;
        var cmd = asString(map, 'cmd');
        if (cmd.isNotEmpty) {
          switch (cmd) {
            case "connected":
              setState(() {
                timeoutValue = asInt(map, 'timeout');
              });
              break;
            case "auth_wait":
              log('You are not logged in.');
              break;
            case "auth_ack":
              log('You are not logged in.');
              break;
            case "auth_nack":
              log('You are not logged in.');
              break;
            case "sign_wait":
              var uuid = asString(map, 'uuid');
              var jsonData = {
                "account": widget.username,
                "uuid": uuid,
                "key": widget.hasKey,
                "host": Communicator.hiveAuthServer
              };
              var jsonString = json.encode(jsonData);
              var utf8Data = utf8.encode(jsonString);
              var qr = base64.encode(utf8Data);
              qr = "has://sign_req/$qr";
              var uri = Uri.tryParse(qr);
              if (uri != null) {
                launchUrl(uri);
              }
              setState(() {
                loadingQR = false;
                qrCode = qr;
                var uri = Uri.tryParse(qr);
                if (uri != null) {
                  launchUrl(uri);
                }
                timer = timeoutValue;
                ticker = Timer.periodic(Duration(seconds: 1), (tickrr) {
                  if (timer == 0) {
                    setState(() {
                      tickrr.cancel();
                      qrCode = null;
                    });
                  } else {
                    setState(() {
                      timer--;
                    });
                  }
                });
              });
              break;
            case "sign_ack":
              widget.onDone();
              Navigator.of(context).pop();
              // var uuid = asString(map, 'uuid');
              // setState(() {
              //   isCompleting = false;
              //   processText = '';
              // });
              // showDialogForAfter10Seconds("Transaction - $uuid was approved. Please hit save button again after 10 seconds to mark video as published.");
              break;
            case "sign_nack":
              setState(() {
                ticker?.cancel();
                qrCode = null;
              });
              showError("Upvote was declined. Please try again.");
              break;
            case "sign_err":
              setState(() {
                ticker?.cancel();
                qrCode = null;
              });
              showError("Upvote action failed.");
              break;
            default:
              log('Default case here');
          }
        }
      }, onError: (e) async {
        await Future.delayed(Duration(seconds: 2));
        socket = WebSocketChannel.connect(
          Uri.parse(Communicator.hiveAuthServer),
        );
      }, onDone: () async {
        await Future.delayed(Duration(seconds: 2));
        socket = WebSocketChannel.connect(
          Uri.parse(Communicator.hiveAuthServer),
        );
      }, cancelOnError: true);
    }
  }

  Widget _upVoteSlider() {
    var data = Provider.of<HiveUserData>(context);
    var user = data.username;
    if (user == null) return Container();
    var voteValue = sliderValue * 100;
    var intVoteValue = voteValue.round();
    return Column(
      children: [
        const Spacer(),
        Slider(
          value: sliderValue,
          min: -1.0,
          divisions: 40,
          label: '${(sliderValue * 100).round()} %',
          activeColor: sliderValue >= 0.0
              ? Theme.of(context).colorScheme.primary
              : Colors.red,
          onChanged: (val) {
            setState(() {
              sliderValue = val;
            });
          },
        ),
        const SizedBox(height: 10),
        Text(
            "$intVoteValue %${sliderValue >= 0.0 ? "" : "\nDownVote discourages content creator.\nPlease be double sure when downVoting 👎 content."}",
            textAlign: TextAlign.center),
        const Spacer(),
      ],
    );
  }

  void saveButtonTapped(HiveUserData data) async {
    setState(() {
      isUpVoting = true;
    });
    try {
      var voteValue = sliderValue * 100;
      var user = data.username;
      if (user == null) return;
      const platform = MethodChannel('com.example.acela/auth');
      final String result = await platform.invokeMethod('voteContent', {
        'user': user,
        'author': widget.author,
        'permlink': widget.permlink,
        'weight': voteValue,
        'postingKey': data.postingKey ?? '',
        'hasKey': data.keychainData?.hasId ?? '',
        'hasAuthKey': data.keychainData?.hasAuthKey ?? '',
      });
      var response = LoginBridgeResponse.fromJsonString(result);
      if (response.valid && response.error.isEmpty) {
        log("Successful upvote and bridge communication");
        if (response.error == "" &&
            response.data != null &&
            response.data!.isNotEmpty &&
            data.keychainData?.hasAuthKey != null) {
          var socketData = {
            "cmd": "sign_req",
            "account": data.username!,
            "token": data.keychainData!.hasId,
            "data": response.data!,
          };
          log('Socket message is - ${json.encode(socketData)}');
          loadingQR = true;
          var jsonData = json.encode(socketData);
          socket.sink.add(jsonData);
        } else {
          setState(() {
            widget.onDone();
            Navigator.of(context).pop();
          });
        }
      }
    } catch (e) {
      showError('Something went wrong.\n${e.toString()}');
    } finally {
      setState(() {
        isUpVoting = false;
      });
    }
  }

  Widget _showQRCodeAndKeychainButton(String qr) {
    return Center(
      child: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: QrImage(
                        data: qr,
                        size: 150.0,
                        gapless: true,
                      ),
                    ),
                    onTap: () {
                      var uri = Uri.tryParse(qr);
                      if (uri != null) {
                        launchUrl(uri);
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      var uri = Uri.tryParse(qr);
                      if (uri != null) {
                        launchUrl(uri);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: Image.asset('assets/hive-keychain-image.png', width: 100),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: timer.toDouble() / timeoutValue.toDouble(),
                  semanticsLabel: 'Timeout Timer for HiveAuth QR',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _listOfVoters() {
  //   return ListView.separated(itemBuilder: (c, i){
  //     return ListTile(
  //       title: Text(widget.activeVotes[i].voter),
  //       subtitle: Text(widget.activeVotes[i].),
  //     );
  //   }, separatorBuilder: (c, i){}, itemCount: widget.activeVotes.length,);
  // }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<HiveUserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          title: Text("Vote content"),
          subtitle: Text("@${widget.author}/${widget.permlink}"),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // widget.onClose();
            Navigator.of(context).pop();
          },
        ),
        actions: isUpVoting || sliderValue == 0.0
            ? []
            : [
                IconButton(
                  onPressed: () {
                    saveButtonTapped(data);
                  },
                  icon: Icon(
                    sliderValue > 0.0
                        ? Icons.thumb_up_sharp
                        : Icons.thumb_down_alt_sharp,
                    color: sliderValue > 0.0 ? Colors.blue : Colors.red,
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child:
        // (widget.activeVotes
        //             .where((element) => element.voter == widget.username)
        //             .length >
        //         0)
        //     ? _listOfVoters()
        //     :
        isUpVoting
                ? qrCode != null
                    ? _showQRCodeAndKeychainButton(qrCode!)
                    : const Center(child: CircularProgressIndicator())
                : qrCode != null
                    ? _showQRCodeAndKeychainButton(qrCode!)
                    : _upVoteSlider(),
      ),
    );
  }
}
