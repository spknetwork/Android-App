import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WorkTypeWidget extends StatefulWidget {
  const WorkTypeWidget(
      {Key? key, required this.isNsfwContent, required this.onChanged})
      : super(key: key);

  final bool isNsfwContent;
  final Function(bool) onChanged;

  @override
  State<WorkTypeWidget> createState() => _WorkTypeWidgetState();
}

class _WorkTypeWidgetState extends State<WorkTypeWidget> {
  late bool isNsfwContent;

  @override
  void initState() {
    isNsfwContent = widget.isNsfwContent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          visualDensity: VisualDensity.compact,
          value: isNsfwContent, onChanged: (newValue) {
            setState(() {
              isNsfwContent = newValue!;
            });
            widget.onChanged(newValue!);
          },),
        Expanded(
          child: Text(
            "You should check this option if your content is NSFW",
            style: TextStyle(color: Colors.red),
              ),
        ),

      ],
    );
  }
}
