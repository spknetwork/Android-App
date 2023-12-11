import 'package:flutter/material.dart';

class BottomSheetOutline extends StatelessWidget {
  const BottomSheetOutline(
      {Key? key, required this.children, this.bottomSheetHeight})
      : super(key: key);

  final List<Widget> children;
  final double? bottomSheetHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: bottomSheetHeight ?? 160,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5,
            width: 60,
            decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: const BorderRadius.all(Radius.circular(16))),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 24.0, right: 24, bottom: 20, top: 30),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: children),
          ),
        ],
      ),
    );
  }
}
