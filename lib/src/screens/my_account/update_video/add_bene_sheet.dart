import 'dart:ffi';

import 'package:acela/src/models/my_account/video_ops.dart';
import 'package:flutter/material.dart';

class AddBeneSheet extends StatefulWidget {
  const AddBeneSheet({Key? key, required this.benes, required this.onSave}) : super(key: key);
  final List<BeneficiariesJson> benes;
  final Function onSave;

  @override
  State<AddBeneSheet> createState() => _AddBeneSheetState();
}

class _AddBeneSheetState extends State<AddBeneSheet> {
  var newBeneValue = 1.0;
  var name = '';

  Widget _beneNameField() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Beneficiary Hive Account Name',
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
    var max = (10000 - widget.benes.map((e) => e.weight).reduce((a, b) => a + b)).toDouble() / 100.0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Beneficiary'),
          actions: [
            IconButton(
              onPressed: () {
                if (name.isEmpty) return;
                widget.onSave(name, (newBeneValue * 100).toInt());
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.add),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _beneNameField(),
              Slider(
                value: newBeneValue.toDouble(),
                min: 1.0,
                max: max,
                activeColor: Theme.of(context).colorScheme.secondary,
                onChanged: (val) {
                  setState(() {
                    newBeneValue = val;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                '${newBeneValue.toStringAsFixed(2)} %',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
