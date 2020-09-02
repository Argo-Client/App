library main;

import 'json/schoolUrls.json.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
part 'introduction/slides.dart';
part 'tabs/Agenda.dart';
part 'tabs/Cijfers.dart';
part 'drawer.dart';

void main() async {
  runApp(new MaterialApp(
    title: 'Magistex',
    theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Colors.blue,
        brightness: Brightness.dark),
    initialRoute: '/',
    routes: {
      '/': (context) => Agenda(),
      'Cijfers': (context) => Cijfers(),
      "Introduction": (context) => Introduction()
    },
  ));
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       color: Colors.blue,
//       home: new Splash(),
//     );
//   }
// }
