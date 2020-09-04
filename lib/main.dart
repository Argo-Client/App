library main;

// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'src/introduction/login.dart';
part 'src/tabs/Instellingen.dart';
part 'src/introduction/Introduction.dart';
part 'src/tabs/home.dart';
part 'src/tabs/Agenda.dart';
part 'src/tabs/Cijfers.dart';

MagisterAuth magisterAuth = new MagisterAuth();
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            home: Home(),
          );
        });
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}
