import 'dart:convert';

import 'package:acela/src/bloc/server.dart';
import 'package:acela/src/models/home_screen_feed_models/hive_payout_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'custom_circle_avatar.dart';

class ListTileVideo extends StatelessWidget {
  const ListTileVideo({
    Key? key,
    required this.placeholder,
    required this.url,
    required this.userThumbUrl,
    required this.title,
    required this.subtitle,
    required this.onUserTap,
    required this.user,
    required this.permlink,
  }) : super(key: key);

  final String placeholder;
  final String url;
  final String userThumbUrl;
  final String title;
  final String subtitle;
  final Function onUserTap;
  final String user;
  final String permlink;

  Widget _errorIndicator() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.asset(placeholder).image,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget _amount(double value) {
    return SizedBox(
      height: 220,
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadiusDirectional.all(Radius.circular(10)),
                    color: Colors.blueGrey),
                child: Text('\$ ${value.toStringAsFixed(3)}'),
              ),
              const SizedBox(height: 5),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Future<HivePayoutResponse> _futureHivePayout() async {
    var request = http.Request('POST', Uri.parse('https://api.deathwing.me/'));
    request.body = json.encode({
      "id": 0,
      "jsonrpc": "2.0",
      "method": "condenser_api.get_content",
      "params": [user, permlink]
    });
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var string = await response.stream.bytesToString();
      return HivePayoutResponse.fromJsonString(string);
    } else {
      throw response.reasonPhrase ?? 'Unknown Error';
    }
  }

  Widget _hivePayoutLoader() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data as HivePayoutResponse;
          if (data.result.pendingPayoutValue == "0.000 HBD") {
            var total = double.parse(
                data.result.totalPayoutValue.replaceAll(' HBD', ''));
            var curator = double.parse(
                data.result.curatorPayoutValue.replaceAll(' HBD', ''));
            return _amount(total + curator);
          } else {
            var value = double.parse(
                data.result.pendingPayoutValue.replaceAll(' HBD', ''));
            return _amount(value);
          }
        } else {
          return Container();
        }
      },
      future: _futureHivePayout(),
    );
  }

  Widget _thumbnailType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 220,
              width: MediaQuery.of(context).size.width,
              child: FadeInImage.assetNetwork(
                placeholder: placeholder,
                image: server.resizedImage(url),
                fit: BoxFit.fitWidth,
                placeholderErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return _errorIndicator();
                },
                imageErrorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return _errorIndicator();
                },
              ),
            ),
            _hivePayoutLoader(),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(3),
          child: Row(
            children: [
              InkWell(
                child: CustomCircleAvatar(
                    height: 45, width: 45, url: userThumbUrl),
                onTap: () {
                  onUserTap();
                },
              ),
              Container(width: 5),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyText1),
                    Row(
                      children: [
                        InkWell(
                          child: Text('👤 $user',
                              style: Theme.of(context).textTheme.bodyText2),
                          onTap: () {
                            onUserTap();
                          },
                        ),
                        const SizedBox(width: 5),
                        Text(subtitle,
                            style: Theme.of(context).textTheme.bodyText2),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnailType(context);
  }
}
