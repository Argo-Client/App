import 'package:argo/src/utils/boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

Brightness getBrightness() {
  Brightness brightness;

  switch (userdata.get("theme")) {
    case "donker":
      brightness = Brightness.dark;
      break;
    case "licht":
      brightness = Brightness.light;
      break;
    case "OLED":
      brightness = Brightness.dark;
      break;
    default:
      brightness = SchedulerBinding.instance.window.platformBrightness;
  }

  return brightness;
}
