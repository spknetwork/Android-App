import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  const CachedImage(
      {Key? key,
      required this.imageUrl,
      this.imageHeight,
      this.imageWidth,
      this.loadingIndicatorSize})
      : super(key: key);

  final String? imageUrl;
  final double? imageHeight;
  final double? imageWidth;
  final double? loadingIndicatorSize;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      height: imageHeight,
      width: imageWidth,
      fit: imageHeight != null ? BoxFit.cover : null,
      progressIndicatorBuilder: (context, url, downloadProgress) =>imageHeight !=null ?
           Center(
                  child: SizedBox(
                      height: loadingIndicatorSize ?? 50,
                      width: loadingIndicatorSize ?? 50,
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 1.5,
                      )),
                ) : CircularProgressIndicator(
                        value: downloadProgress.progress,
                        strokeWidth: 1.5,
                      ) ,
      errorWidget: (context, url, error) => Image.asset(
        'assets/ctt-logo.png',
        height: imageHeight,
        width: imageWidth,
      ),
    );
  }
}
