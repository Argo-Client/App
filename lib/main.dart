library main;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'src/Magister/login.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'src/introduction/Introduction.dart';
part 'src/layout.dart';
part 'src/tabs/Thuis.dart';
part 'src/tabs/Agenda.dart';
part 'src/tabs/Cijfers.dart';
part 'src/tabs/Huiswerk.dart';
part 'src/tabs/Afwezigheid.dart';
part 'src/tabs/Berichten.dart';
part 'src/tabs/Studiewijzer.dart';
part 'src/tabs/Opdrachten.dart';
part 'src/tabs/Leermiddelen.dart';
part 'src/tabs/Bronnen.dart';
part 'src/tabs/MijnGegevens.dart';
part 'src/tabs/Instellingen.dart';

MagisterAuth magisterAuth = new MagisterAuth();
BuildContext mainContext;
Box userdata;
void main() async {
  await Hive.initFlutter();
  await Hive.openBox("userdata");
  userdata = Hive.box("userdata");
  runApp(App());
  await Hive.openBox("magisterTokens");
  print("Userdata: " + userdata.toMap().toString());
  print("magisterTokens: " + Hive.box("magisterTokens").toMap().toString());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    mainContext = context;
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primaryColor: Colors.blue,
              accentColor: Colors.blue,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return MaterialApp(
            title: 'Magistex',
            theme: theme,
            initialRoute: "/",
            routes: {
              "/": (context) => Home(),
              "Introduction": (context) => Introduction(),
            },
            // home: Home(),
          );
        });
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}
