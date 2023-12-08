import 'package:acela/src/bloc/server.dart';
import 'package:flutter/material.dart';

class UserProfileImage extends StatelessWidget {
  const UserProfileImage({Key? key, required this.userName}) : super(key: key);

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade800,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            server.userOwnerThumb(userName),
          ),
        ),
      ),
    );
  }
}
