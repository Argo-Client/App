import 'package:flutter/material.dart';
import 'package:Argo/src/layout.dart';

class Opdrachten extends StatefulWidget {
  @override
  _Opdrachten createState() => _Opdrachten();
}

class _Opdrachten extends State<Opdrachten> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            DrawerStates.layoutKey.currentState.openDrawer();
          },
        ),
        title: Text("Opdrachten"),
      ),
      body: Center(
        child: Text("63 opdrachten in te leveren voor het eind van deze week"),
      ),
    );
  }
}
