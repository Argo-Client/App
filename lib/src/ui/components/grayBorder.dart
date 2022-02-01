import 'package:argo/src/utils/getBrightness.dart';
import 'package:flutter/material.dart';
import 'package:argo/src/utils/boxes.dart';

Color grayBorderColor() {
  Color color;

  if (userdata.get("useBorderColor")) {
    return userdata.get("borderColor");
  }

  String theme = userdata.get("theme");

  if (theme == "systeem") {
    theme = getBrightness() == Brightness.light ? "licht" : "donker";
  }

  switch (theme) {
    case "OLED":
      color = Color(0xFF323232);
      break;
    case "donker":
      color = Color(0xFF646464);
      break;
    case "licht":
      color = Color(0xFFe1e1e1);
      break;
    default:
      throw "${userdata.get("theme")} is een onjuist thema";
  }
  return color;
}

BorderSide defaultBorderSide(context) {
  return BorderSide(
    color: Theme.of(context).dividerColor,
    width: 1,
  );
}
