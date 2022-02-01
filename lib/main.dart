import 'package:argo/src/ui/components/grayBorder.dart';
import 'package:argo/src/utils/background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:developer';

import 'package:argo/src/utils/hive/adapters.dart';
import 'package:argo/src/utils/hive/init.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:argo/src/utils/getBrightness.dart';

import 'package:argo/src/layout.dart';

_AppState appState;
ValueNotifier<List> errorLog = ValueNotifier([]);

void main() async {
  await initHive();
  Box<Account> accounts = Hive.box("accounts");
  Box userdata = Hive.box("userdata");

  log("Userdata: " + userdata.toMap().toString());
  log("Accounts: " + accounts.toMap().toString());

  if (accounts.isEmpty) {
    userdata.delete("introduction");
  }

  Map standardSettings = {
    "theme": "systeem",
    "primaryColor": Colors.blue,
    "accentColor": Colors.orange,
    "borderColor": Colors.black,
    "useBorderColor": false,
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
    "lessonNotifications": true,
    "preNotificationMinutes": 10,
    "lessonNotificationsExpire": true,
    "lessonNotificationExpiry": 30,
    "developerMode": false,
    "disableCijferColor": false,
    "useVakName": false,
    "showStatus5": false,
  };

  standardSettings.entries.forEach((setting) {
    if (!userdata.containsKey(setting.key)) userdata.put(setting.key, setting.value);
  });

  if (userdata.get("alwaysPrimary") || !accounts.containsKey(userdata.get("accountIndex"))) {
    int firstAccIndex = accounts.isEmpty ? 0 : accounts.keys.first;
    userdata.put("accountIndex", firstAccIndex);
  }

  if (accounts.isNotEmpty) {
    // Als je de app voor het eerst opent heb je nog geen account
    Notifications().scheduleBackground();
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
    final Color blackForOLED = userdata.get("theme") == "OLED" ? Colors.black : null;

    return MaterialApp(
      title: 'Argo',
      theme: ThemeData(
        brightness: getBrightness(),
        scaffoldBackgroundColor: blackForOLED,
        primaryColor: blackForOLED ?? userdata.get("primaryColor"),
        accentColor: userdata.get("accentColor"),
        dividerColor: grayBorderColor(),
        backgroundColor: blackForOLED,
        dialogBackgroundColor: blackForOLED,
        cardColor: blackForOLED,
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
