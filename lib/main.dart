library main;

import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'src/Magister/login.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'src/introduction/Introduction.dart';
part 'src/layout.dart';
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
Box userdata;
void main() async {
  await Hive.initFlutter();
  await Hive.openBox("magisterTokens");
  await Hive.openBox("userdata");
  userdata = Hive.box("userdata");
  runApp(App());
}

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
            home: userdata.containsKey("introduction") ? Home() : Introduction(),
          );
        });
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}
