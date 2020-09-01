library main;

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:after_layout/after_layout.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'introduction/introduction.dart';
part 'introduction/slides.dart';
part 'tabs/Agenda.dart';
part 'tabs/Cijfers.dart';
part 'drawer.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Colors.blue,
      home: new Splash(),
    );
  }
}
