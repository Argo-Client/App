import 'package:flutter/material.dart';
import 'package:argo/main.dart';

class CircleShape extends StatelessWidget {
  final Widget child;

  CircleShape({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: userdata.get("accentColor")),
      ),
      width: 45,
      height: 45,
      child: Center(
        child: child,
      ),
    );
  }
}
