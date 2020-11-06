library main;

import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'dart:developer';
import 'dart:convert';
import 'dart:async';

import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flushbar/flushbar.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:futuristic/futuristic.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:filesize/filesize.dart';
// import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:charts_flutter/flutter.dart' as charts;
// import 'package:flutter_date_pickers/flutter_date_pickers.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/utils/magister/login.dart';
import 'src/utils/hive/adapters.dart';
part 'src/ui/Introduction.dart';
part 'src/utils/tabs.dart';
part 'src/layout.dart';

part 'src/ui/tabs/Thuis.dart';
part 'src/ui/tabs/Agenda.dart';
part 'src/ui/tabs/Cijfers.dart';
part 'src/ui/tabs/Huiswerk.dart';
part 'src/ui/tabs/Afwezigheid.dart';
part 'src/ui/tabs/Berichten.dart';
part 'src/ui/tabs/Studiewijzer.dart';
part 'src/ui/tabs/Opdrachten.dart';
part 'src/ui/tabs/Leermiddelen.dart';
part 'src/ui/tabs/Bronnen.dart';
part 'src/ui/tabs/MijnGegevens.dart';
part 'src/ui/tabs/Instellingen.dart';
part 'src/ui/tabs/Info.dart';

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${this.substring(1)}";
}

class SeeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final Color color;

  SeeCard({this.margin, this.child, this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      color: color ?? null,
      child: child,
    );
  }
}

Account account;
_AppState appState;
Box userdata, accounts, custom;
Brightness theme;
ValueNotifier<bool> updateNotifier = ValueNotifier(false);
void update() => updateNotifier.value = !updateNotifier.value;
Future handleError(Function fun, String msg, BuildContext context, [Function cb]) async {
  if (account.id != 0) {
    try {
      await fun();
      update();
      if (cb != null) cb();
    } catch (e) {
      String flush = "$msg:\n$e";
      try {
        flush = "$msg:\n${e.error}";
      } catch (_) {
        throw (e);
      }
      FlushbarHelper.createError(message: flush)..show(context);
    }
  }
}

void main() async {
  await Hive.initFlutter();
  try {
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(ColorAdapter());
    Hive.registerAdapter(MaterialColorAdapter());
    // Hive.registerAdapter(IconAdapter());
    Hive.registerAdapter(LesAdapter());
    Hive.registerAdapter(CijferJaarAdapter());
    Hive.registerAdapter(CijferAdapter());
    Hive.registerAdapter(VakAdapter());
    Hive.registerAdapter(PeriodeAdapter());
    Hive.registerAdapter(BerichtAdapter());
    Hive.registerAdapter(AbsentieAdapter());
    Hive.registerAdapter(BronAdapter());
    Hive.registerAdapter(WijzerAdapter());
  } catch (e) {}
  userdata = await Hive.openBox("userdata");
  accounts = await Hive.openBox<Account>("accounts");
  custom = await Hive.openBox("custom");
  if (accounts.isEmpty) {
    userdata.delete("introduction");
    userdata.putAll({
      "theme": "systeem",
      "primaryColor": Colors.blue,
      "accentColor": Colors.orange,
      "useIcon": false,
      "accountIndex": 0,
      "pixelsPerHour": 75,
      "agendaStartHour": 8,
      "agendaEndHour": 17,
      "agendaAutoBegin": true,
      "agendaAutoEind": true,
      "backOpensDrawer": true,
    });
    accounts.put(0, Account());
  }
  log("Userdata: " + userdata.toMap().toString());
  log("accounts: " + accounts.toMap().toString());
  int accountIndex = userdata.get("accountIndex");
  account = accounts.get(accountIndex) ?? accounts.get(accounts.toMap().entries.first.key);
  appState = _AppState();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => appState;
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    switch (userdata.get("theme")) {
      case "donker":
        theme = Brightness.dark;
        break;
      case "licht":
        theme = Brightness.light;
        break;
      default:
        theme = SchedulerBinding.instance.window.platformBrightness;
    }
    return MaterialApp(
      title: 'Argo',
      theme: ThemeData(
        brightness: theme,
        primaryColor: userdata.get("primaryColor"),
        accentColor: userdata.get("accentColor"),
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// HomeState homeState = HomeState();

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}
