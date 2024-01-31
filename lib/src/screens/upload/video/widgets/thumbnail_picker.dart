import 'package:acela/src/models/video_upload/upload_response.dart';
import 'package:acela/src/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ThumbnailPicker extends StatefulWidget {
  const ThumbnailPicker(
      {Key? key,
      required this.thumbnailUploadProgress,
      required this.thumbnailUploadRespone,
      required this.onUploadFile,
      required this.thumbnailUploadStatus})
      : super(key: key);

  final ValueNotifier<double> thumbnailUploadProgress;
  final ValueNotifier<UploadResponse?> thumbnailUploadRespone;
  final Function(XFile) onUploadFile;
  final ValueNotifier<UploadStatus> thumbnailUploadStatus;

  @override
  State<ThumbnailPicker> createState() => _ThumbnailPickerState();
}

class _ThumbnailPickerState extends State<ThumbnailPicker> {
  bool isPickingImage = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
        width: 320,
        height: 160,
        child: ValueListenableBuilder<UploadStatus>(
          valueListenable: widget.thumbnailUploadStatus,
          builder: (context, uploadStatus, child) {
            return InkWell(
              child: ValueListenableBuilder<double>(
                valueListenable: widget.thumbnailUploadProgress,
                builder: (context, progress, child) {
                  return Center(
                    child: uploadStatus == UploadStatus.started
                        ? CircularProgressIndicator(
                            value: progress,
                            valueColor: AlwaysStoppedAnimation<Color?>(
                                theme.primaryColorLight),
                            backgroundColor: !isPickingImage
                                ? theme.primaryColorLight.withOpacity(0.4)
                                : null,
                          )
                        : ValueListenableBuilder<UploadResponse?>(
                            valueListenable: widget.thumbnailUploadRespone,
                            builder: (context, value, child) {
                              return value != null
                                  ? Image.network( value.url)
                                  : const Text(
                                      'Tap here to add thumbnail for your video\n\nThumbnail is MANDATORY to set.',
                                      textAlign: TextAlign.center);
                            },
                          ),
                  );
                },
              ),
              onTap: () async {
                await _onTap(uploadStatus);
              },
            );
          },
        ));
  }

  Future<void> _onTap(UploadStatus uploadStatus) async {
    if (uploadStatus != UploadStatus.started) {
      try {
        setState(() {
          isPickingImage = true;
        });
        final XFile? file =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (file != null) {
          setState(() {
            isPickingImage = false;
          });
          widget.onUploadFile(file);
        } else {
          throw 'User cancelled image picker';
        }
      } catch (e) {
        showError(e.toString());
        setState(() {
          isPickingImage = false;
        });
      }
    }
  }

   void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
