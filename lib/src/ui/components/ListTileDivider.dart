import 'package:argo/src/ui/components/grayBorder.dart';
import 'package:flutter/material.dart';

List<Widget> divideListTiles(List<Widget> children) {
  final List<Widget> items = [];
  for (var child in children) {
    items.add(
      DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: child == children.last
              ? null
              : Border(
                  bottom: BorderSide(
                    color: grayBorderColor(),
                  ),
                ),
        ),
        child: child,
      ),
    );
  }
  return items;
}
