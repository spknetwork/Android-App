import 'package:flutter/material.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({Key? key}) : super(key: key);

  Widget _drawerHeaderText(BuildContext context) {
    return Column(
      children: [
        Text(
          "Acela",
          style: Theme.of(context).textTheme.headline5,
        ),
        Text(
          "3Speak.tv",
          style: Theme.of(context).textTheme.headline6,
        ),
      ],
    );
  }

  Widget _drawerHeader(BuildContext context) {
    return DrawerHeader(child: _drawerHeaderText(context));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        _drawerHeader(context),
      ],
    ));
  }
}
