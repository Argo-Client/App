import 'package:flutter/material.dart';
import 'package:argo/src/utils/boxes.dart';
import 'package:argo/src/utils/getBrightness.dart';

BorderSide greyBorderSide() {
  Color color;
  if (getBrightness() == Brightness.dark) {
    if (userdata.get("theme") == "OLED") {
      color = Color.fromARGB(
        255,
        50,
        50,
        50,
      );
    } else {
      color = Color.fromARGB(
        255,
        100,
        100,
        100,
      );
    }
  } else {
    color = Color.fromARGB(
      255,
      225,
      225,
      225,
    );
  }

  return BorderSide(color: color, width: 1);
}
