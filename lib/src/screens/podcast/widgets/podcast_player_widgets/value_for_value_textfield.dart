import 'package:flutter/material.dart';

class ValueForValueTextField extends StatelessWidget {
  const ValueForValueTextField(
      {Key? key,
      required this.textEditingController,
      required this.hinttext,
      this.maxLines,
      this.keyboardType})
      : super(key: key);

  final TextEditingController textEditingController;
  final String hinttext;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textEditingController,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade800,
          filled: true,
          isDense: true,
          hintText: hinttext,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border),
    );
  }

  InputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      );
}
