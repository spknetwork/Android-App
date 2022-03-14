import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var text = '';
  late TextEditingController _controller;

  Future<void> search()  async{
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': dotenv.env['HIVE_SEARCHER_AUTH_KEY'] ?? ''
    };
    var request = http.Request('POST', Uri.parse('https://api.hivesearcher.com/search'));
    request.body = json.encode({
      "q": "sagarkothari88 Watch on 3speak type:post",
      "sort": "newest"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      log(await response.stream.bytesToString());
    } else {
      log(response.reasonPhrase.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: (value) {
            log('Text changed to $value');
          },
        ),
      ),
      body: const Center(
        child: Text('Text search'),
      ),
    );
  }
}
