import 'package:flutter/material.dart';

import 'package:argo/src/ui/tabs/Afwezigheid.dart';
import 'package:argo/src/ui/tabs/Agenda.dart';
import 'package:argo/src/ui/tabs/Berichten.dart';
import 'package:argo/src/ui/tabs/Bronnen.dart';
import 'package:argo/src/ui/tabs/Cijfers.dart';
import 'package:argo/src/ui/tabs/Huiswerk.dart';
import 'package:argo/src/ui/tabs/Info.dart';
import 'package:argo/src/ui/tabs/Instellingen.dart';
import 'package:argo/src/ui/tabs/Leermiddelen.dart';
import 'package:argo/src/ui/tabs/MijnGegevens.dart';
import 'package:argo/src/ui/tabs/Studiewijzer.dart';
import 'package:argo/src/ui/tabs/Thuis.dart';
// import 'package:argo/src/ui/tabs/Opdrachten.dart';

import 'package:argo/src/utils/hive/adapters.dart';

class TabItem {
  Widget page;
  String name;
  IconData icon;
  Color color;
  bool overridesPop;
  bool dividerBelow;

  TabItem({
    @required this.page,
    @required this.name,
    @required this.icon,
    @required this.color,
    this.overridesPop = false,
    this.dividerBelow = false,
  });
}

class Tabs {
  Account account;
  List<TabItem> children;

  Tabs(this.account) {
    if (account == null) {
      children = [];
      return;
    }
    children = [
      TabItem(
        page: Thuis(),
        name: "Vandaag",
        icon: Icons.home_outlined,
        color: Colors.orange,
      ),
      TabItem(
        page: Agenda(),
        name: "Agenda",
        icon: Icons.event_outlined,
        color: Colors.blue,
      ),

      if (account.has("Afspraken", "Read"))
        TabItem(
          page: Huiswerk(),
          name: "Huiswerk",
          icon: Icons.assignment_outlined,
          color: Colors.green[600],
        ),
      if (account.has("Absenties", "Read"))
        TabItem(
          page: Afwezigheid(),
          name: "Afwezigheid",
          icon: Icons.check_circle_outlined,
          color: Colors.redAccent,
        ),
      if (account.has("Cijfers", "Read"))
        TabItem(
          page: Cijfers(),
          name: "Cijfers",
          icon: Icons.looks_6_outlined,
          color: Colors.cyan[800],
        ),
      if (account.has("Berichten", "Read"))
        TabItem(
          page: Berichten(),
          name: "Berichten",
          icon: Icons.email_outlined,
          color: Colors.purple,
          dividerBelow: true,
        ),
      if (account.has("Studiewijzers", "Read"))
        TabItem(
          page: Studiewijzers(),
          name: "Studiewijzers",
          icon: Icons.school_outlined,
          color: Colors.amber,
        ),
      if (account.has("DigitaalLesmateriaal", "Read"))
        TabItem(
          page: Leermiddelen(),
          name: "Leermiddelen",
          icon: Icons.language_outlined,
          color: Colors.cyan,
        ),
      // {
      //   "name": Text("Opdrachten"),
      //   "icon": Icons.assignment_late_outlined,
      //   "page": Opdrachten(),
      //   "overridePop": true,
      //   "color": Colors.red[600],
      // },
      if (account.has("Bronnen", "Read"))
        TabItem(
          page: Bronnen(),
          name: "Bronnen",
          icon: Icons.folder_outlined,
          color: Colors.indigo[200],
          overridesPop: true,
          dividerBelow: true,
        ),
      if (account.has("Profiel", "Read"))
        TabItem(
          page: MijnGegevens(),
          name: "Mijn Gegevens",
          icon: Icons.person_outlined,
          color: Colors.pink[200],
        ),
      TabItem(
        page: Instellingen(),
        name: "Instellingen",
        icon: Icons.settings_outlined,
        color: Colors.blue[200],
      ),
      TabItem(
        page: Info(),
        name: "Info",
        icon: Icons.info_outlined,
        color: Colors.lime[700],
      ),
    ];
  }
}
