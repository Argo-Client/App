library main;

import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' as scheduler;
import 'dart:developer';
import 'dart:convert';
import 'dart:async';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:futuristic/futuristic.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:filesize/filesize.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:Argo/src/utils/notifications.dart';
// import 'package:get_version/get_version.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/utils/login.dart';
import 'src/utils/hive/adapters.dart';

import 'src/ui/CustomWidgets.dart';
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

double bodyHeight(context) => MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - kToolbarHeight;
Account account;
_AppState appState;
Box userdata, accounts, custom;
Brightness theme;
ValueNotifier<bool> updateNotifier = ValueNotifier(false);

Notifications notifications = Notifications();
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
    Hive.registerAdapter(LeermiddelAdapter());
    Hive.registerAdapter(DocentAdapter());
  } catch (_) {}
  try {
    List<Box> boxes = await Future.wait([
      Hive.openBox("userdata"),
      Hive.openBox("custom"),
      Hive.openBox<Account>("accounts"),
    ]);
    userdata = boxes.removeAt(0);
    custom = boxes.removeAt(0);
    accounts = boxes.removeAt(0);
  } catch (e) {
    Hive.deleteBoxFromDisk("accounts");
    return main();
  }
  if (accounts.isEmpty) {
    userdata.delete("introduction");
  }
  Map standardSettings = {
    "theme": "systeem",
    "primaryColor": Colors.blue,
    "accentColor": Colors.orange,
    "useIcon": false,
    "accountIndex": 0,
    "pixelsPerHour": 75,
    "agendaStartHour": 8,
    "agendaEndHour": 17,
    "agendaAutoBegin": false,
    "agendaAutoEind": false,
    "backOpensDrawer": true,
    "doubleBackAgenda": true,
    "colorsInDrawer": true,
    "alwaysPrimary": true,
    "preNotificationMinutes": 20,
  };
  standardSettings.entries.forEach((element) {
    if (!userdata.containsKey(element.key)) userdata.put(element.key, element.value);
  });
  log("Userdata: " + userdata.toMap().toString());
  log("accounts: " + accounts.toMap().toString());
  if (accounts.isNotEmpty) {
    // Als je de app voor het eerst opent heb je nog geen account
    int firstAccIndex = accounts.toMap().entries.first.key;
    if (userdata.get("alwaysPrimary")) {
      userdata.put("accountIndex", firstAccIndex);
    }
    account = accounts.get(userdata.get("accountIndex")) ?? accounts.get(firstAccIndex);
    notifications.lessonNotifications(account.lessons);
  }
  // Hive.deleteFromDisk();
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
    Color backgroundColor;
    switch (userdata.get("theme")) {
      case "donker":
        theme = Brightness.dark;
        break;
      case "licht":
        theme = Brightness.light;
        break;
      case "OLED":
        theme = Brightness.dark;
        backgroundColor = Colors.black;
        break;
      default:
        theme = scheduler.SchedulerBinding.instance.window.platformBrightness;
    }
    return MaterialApp(
      title: 'Argo',
      theme: ThemeData(
        brightness: theme,
        scaffoldBackgroundColor: backgroundColor,
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
