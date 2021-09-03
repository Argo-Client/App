import 'package:flutter/material.dart';
import 'package:argo/src/utils/boxes.dart';

class ContentHeader extends StatelessWidget {
  final String text;

  ContentHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        top: 12.5,
        bottom: 12.5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: userdata.get("accentColor"),
        ),
      ),
    );
  }
}
