import 'package:flutter/material.dart';

class BoxTrail extends StatelessWidget {
  const BoxTrail(
      {
      this.width,
      this.margin,
      this.height,
      this.borderRadius,
      this.shape});

  final double? width;
  final double? margin;
  final double? height;
  final double? borderRadius;
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 10,
      width: width ?? double.infinity,
      margin: EdgeInsets.only(right: margin ?? 0),
      decoration: BoxDecoration(
          shape: shape ?? BoxShape.rectangle,
          color: Colors.grey.shade900,
          borderRadius: shape == null
              ? BorderRadius.all(
                  Radius.circular(borderRadius ?? 30),
                )
              : null),
    );
  }
}
