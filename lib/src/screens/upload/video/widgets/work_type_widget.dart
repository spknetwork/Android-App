import 'package:flutter/material.dart';

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
      children: [
        Text(isNsfwContent
            ? 'Video is NOT SAFE for work.'
            : 'Video is Safe for work.'),
        const Spacer(),
        Switch(
          value: isNsfwContent,
          onChanged: (newValue) {
            setState(() {
              isNsfwContent = newValue;
            });
            widget.onChanged(newValue);
          },
        )
      ],
    );
  }
}
