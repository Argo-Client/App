library main;

import 'src/data/schools.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'src/introduction/slides.dart';
part 'src/tabs/home.dart';
part 'src/tabs/Agenda.dart';
part 'src/tabs/Cijfers.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magistex',
      theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.blue,
          brightness: Brightness.dark),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}
