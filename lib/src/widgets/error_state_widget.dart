import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    Key? key,
    required this.onRetry,
  }) : super(key: key);
  final Function onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Row(children: const [
          Spacer(),
          Text(
            'Oops! Something went wrong.\nPlease Try again.',
            textAlign: TextAlign.center,
          ),
          Spacer(),
        ]),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            onRetry();
          },
          child: const Text('Retry'),
        ),
        const Spacer(),
      ],
    );
  }
}