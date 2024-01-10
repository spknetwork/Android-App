import 'package:flutter/material.dart';

class AddNodeByUrl extends StatefulWidget {
  const AddNodeByUrl({Key? key, required this.onAdd, required this.title})
      : super(key: key);
  final Function(String) onAdd;

  final String title;

  @override
  State<AddNodeByUrl> createState() => _AddRssPodcastState();
}

class _AddRssPodcastState extends State<AddNodeByUrl> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Add ${widget.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15.0),
        child: _body(),
      ),
    );
  }

  Column _body() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 30),
        child: Icon(
          Icons.new_label,
          size: 60,
        ),
      ),
      Text(
        "Add ${widget.title} node by Url",
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 8,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: TextField(
          controller: textEditingController,
          decoration: InputDecoration(
              fillColor: Colors.grey.shade800,
              filled: true,
              hintText: "Enter URL",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none),
        ),
      ),
      SizedBox(
        width: 125,
        child: TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: onAdd,
          child: Text(
            "Save",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      )
    ]);
  }

  void onAdd() async {
    if (textEditingController.text.trim().isNotEmpty) {
      widget.onAdd(textEditingController.text.trim());
    }
  }
}
