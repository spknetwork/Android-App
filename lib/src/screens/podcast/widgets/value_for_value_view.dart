import 'package:acela/src/screens/podcast/widgets/podcast_player_widgets/value_for_value_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ValueForValueView extends StatefulWidget {
  const ValueForValueView({Key? key}) : super(key: key);

  @override
  State<ValueForValueView> createState() => _ValueForValueViewState();
}

class _ValueForValueViewState extends State<ValueForValueView> {
  final TextEditingController sats = TextEditingController();
  final TextEditingController message = TextEditingController();

  @override
  void dispose() {
    sats.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡️Value For Value⚡️'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(children: [
          ValueForValueTextField(
              keyboardType: TextInputType.number,
              textEditingController: sats,
              hinttext: 'Enter Sats'),
          const SizedBox(
            height: 15,
          ),
          ValueForValueTextField(
              textEditingController: message,
              maxLines: 3,
              hinttext: 'Optional public message'),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        label: Row(
          children: [
            Icon(
              CupertinoIcons.gift_fill,
              size: 25,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Boost it!',
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
    );
  }
}
