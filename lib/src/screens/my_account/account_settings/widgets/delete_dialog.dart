import 'package:acela/src/screens/my_account/account_settings/widgets/dialog_button.dart';
import 'package:flutter/material.dart';

class DeleteDialog extends StatefulWidget {
  const DeleteDialog({Key? key, required this.onDelete}) : super(key: key);

  final VoidCallback onDelete;

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool enableDeleteButton = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        enableDeleteButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 20, right: 20),
      title: Text(
        "Delete Account",
      ),
      content: Text(
        "Your account will be deleted permanently",
      ),
      actions: <Widget>[
        DialogButton(
          text: "Cancel",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Stack(
          children: [
            DialogButton(
              text: "Delete",
              color:
                  enableDeleteButton ? Colors.red : Colors.red.withOpacity(0.5),
              onPressed: widget.onDelete,
            ),
            Positioned.fill(
              child: Visibility(
                visible: !enableDeleteButton,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
