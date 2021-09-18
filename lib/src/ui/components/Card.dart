import 'package:flutter/material.dart';
import 'package:argo/src/utils/boxes.dart';

// ignore: must_be_immutable
class MaterialCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Border border;
  final double width;
  final double height;
  final List<Widget> children;
  final EdgeInsets padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  Color color;

  MaterialCard({
    this.width,
    this.height,
    this.margin,
    this.child,
    this.color,
    this.border,
    this.children,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (color == null && userdata.get("theme") == "OLED") {
      color = Colors.black;
    }

    return Container(
      width: width,
      height: height,
      decoration: border == null
          ? null
          : BoxDecoration(
              border: border,
            ),
      child: Card(
        margin: margin ?? EdgeInsets.zero,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: color,
        child: Container(
          padding: padding,
          child: children != null
              ? Column(
                  mainAxisAlignment: mainAxisAlignment,
                  crossAxisAlignment: crossAxisAlignment,
                  children: children,
                )
              : child,
        ),
      ),
    );
  }
}
