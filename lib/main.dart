import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:developer';
import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/getBrightness.dart';

import 'package:argo/src/utils/notifications.dart';
import 'package:argo/src/layout.dart';

_AppState appState;
ValueNotifier<List> errorLog = ValueNotifier([]);

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
  Box accounts;
  Box userdata;
  try {
    List<Box> boxes = await Future.wait([
      Hive.openBox<Account>("accounts"),
      Hive.openBox("userdata"),
      Hive.openBox("custom"),
    ]);
    accounts = boxes.removeAt(0);
    userdata = boxes.removeAt(0);
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
    "disableCijferColor": false,
    "useVakName": false,
  };

  standardSettings.entries.forEach((setting) {
    if (!userdata.containsKey(setting.key)) userdata.put(setting.key, setting.value);
  });

  log("Userdata: " + userdata.toMap().toString());
  log("Accounts: " + accounts.toMap().toString());

  if (accounts.isNotEmpty) {
    // Als je de app voor het eerst opent heb je nog geen account
    notifications.lessonNotifications();
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
  Box userdata = Hive.box("userdata");
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Argo',
      theme: ThemeData(
        brightness: getBrightness(),
        scaffoldBackgroundColor: userdata.get("theme") == "OLED" ? Colors.black : null,
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
