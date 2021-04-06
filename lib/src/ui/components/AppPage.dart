import 'package:flutter/material.dart';
import 'package:argo/src/layout.dart';

class AppPage extends StatelessWidget {
  final Widget title;
  final List<Widget> actions;
  final Widget body;
  final PreferredSizeWidget bottom;

  AppPage({this.title, this.actions, this.body, this.bottom});

  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: actions,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              DrawerStates.layoutKey.currentState.openDrawer();
            },
          ),
          title: title,
          bottom: bottom,
        ),
        body: body,
      );
}
