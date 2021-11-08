import 'package:flutter/material.dart';
import 'package:argo/src/utils/bodyHeight.dart';

class EmptyPage extends StatelessWidget {
  final String text;
  final IconData icon;

  EmptyPage({
    this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          width: double.infinity,
          height: bodyHeight(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: Colors.grey[400],
              ),
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
