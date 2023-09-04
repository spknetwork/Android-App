import 'package:acela/src/models/my_account/video_ops.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class AddBeneSheet extends StatefulWidget {
  const AddBeneSheet({
    Key? key,
    required this.benes,
    required this.onSave,
  }) : super(key: key);
  final List<BeneficiariesJson> benes;
  final Function onSave;

  @override
  State<AddBeneSheet> createState() => _AddBeneSheetState();
}

class _AddBeneSheetState extends State<AddBeneSheet> {
  var newBeneValue = 100;
  var name = '';
  var _controller = TextEditingController();

  Widget _beneNameField() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Video Participant Hive Account Name',
          labelText: 'Account Name',
        ),
        onChanged: (text) {
          setState(() {
            name = text;
          });
        },
        maxLines: 1,
        minLines: 1,
        maxLength: 150,
      ),
    );
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showMessage(String string) {
    var snackBar = SnackBar(content: Text(string));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var author =
        widget.benes.where((element) => element.src == 'author').firstOrNull;
    var max = ((author?.weight ?? 99) - 1) * 100;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Participant'),
          actions: [
            IconButton(
              onPressed: () {
                if (author == null) return;
                if (name.isEmpty) return;
                var names =
                    widget.benes.map((e) => e.account.toLowerCase()).toList();
                var participant = name.toLowerCase().trim();
                if (names.contains(participant)) {
                  showError('Video Participant already added');
                } else {
                  var percentValue = newBeneValue ~/ 100;
                  var newList = widget.benes;
                  newList.add(
                    BeneficiariesJson(
                      account: participant,
                      weight: percentValue,
                      src: 'participant',
                    ),
                  );
                  newList = newList.where((e) => e.src != 'author').toList();
                  var sum = newList.map((e) => e.weight).toList().sum;
                  var newWeight = 100 - sum;
                  newList.add(
                    BeneficiariesJson(
                        account: author.account, weight: newWeight, src: 'author'),
                  );
                  widget.onSave(newList);
                  Navigator.of(context).pop();
                }
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: SafeArea(
          child: (author == null)
              ? Container()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _beneNameField(),
                      Slider(
                        value: newBeneValue.toDouble(),
                        min: 100.0,
                        max: max.toDouble(),
                        activeColor: Theme.of(context).colorScheme.secondary,
                        onChanged: (val) {
                          setState(() {
                            newBeneValue = val.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${(newBeneValue / 100).toStringAsFixed(0)} %',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
