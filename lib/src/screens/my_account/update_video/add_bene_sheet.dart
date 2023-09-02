import 'package:acela/src/models/my_account/video_ops.dart';
import 'package:flutter/material.dart';

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

  Widget _beneNameField() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
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

  @override
  Widget build(BuildContext context) {
    var max = 9900;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Participant'),
          actions: [
            IconButton(
              onPressed: () {
                if (name.isEmpty) return;
                widget.onSave(name, newBeneValue);
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
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
