library main;

import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';

import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:after_layout/after_layout.dart';
import 'package:intl/intl.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/utils/magister/login.dart';
import 'src/utils/hiveObjects.dart';
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

MagisterAuth magisterAuth = new MagisterAuth();
Account account;
_AppState appState;
Box userdata, accounts;
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(ColorAdapter());
  Hive.registerAdapter(MaterialColorAdapter());
  Hive.registerAdapter(IconAdapter());
  userdata = await Hive.openBox("userdata");
  accounts = await Hive.openBox<Account>("accounts");
  log("Userdata: " + userdata.toMap().toString());
  log("accounts: " + accounts.toMap().toString());
  if (!userdata.containsKey("dummyData")) {
    userdata.putAll({
      "darkMode": false,
      "primaryColor": Colors.blue,
      "accentColor": Colors.orange,
      "userIcon": Icons.person,
      "dummyData": true,
      "accountIndex": 0,
    });
    print("Wrote dummy data");
    accounts.put(0, Account());
  }
  // Hive.deleteFromDisk();
  // print("Deleted data");
  // return;
  int accountIndex = userdata.get("accountIndex");
  account = accounts.get(accountIndex);
  log(account.toJson().toString());
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
    return MaterialApp(
      title: 'Magistex',
      theme: ThemeData(
        brightness: userdata.get("darkMode") ? Brightness.dark : Brightness.light,
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
