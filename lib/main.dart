import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' as scheduler;
import 'dart:developer';
import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/utils/hive/adapters.dart';

import 'package:argo/src/utils/notifications.dart';
import 'src/layout.dart';

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${this.substring(1)}";
}

double bodyHeight(context) => MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - kToolbarHeight;
Account account;
_AppState appState;
Box userdata, accounts, custom;
Brightness theme;
ValueNotifier<bool> updateNotifier = ValueNotifier(false);
ValueNotifier<List> errorLog = ValueNotifier([]);

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
    Hive.registerAdapter(PrivilegeAdapter());
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
    print(e);

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
    "colorsInDrawer": false,
    "alwaysPrimary": true,
    "preNotificationMinutes": 10,
    "developerMode": false,
    "liveList": false,
    "pinned": <Wijzer>[],
    "disableCijferColor": false,
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

  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    errorLog.value = List.from(errorLog.value)..add(errorDetails);
    print(errorDetails);
  };
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => appState = _AppState();
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
