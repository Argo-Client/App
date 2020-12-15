import 'package:flutter/material.dart';

import 'package:Argo/src/ui/tabs/Afwezigheid.dart';
import 'package:Argo/src/ui/tabs/Agenda.dart';
import 'package:Argo/src/ui/tabs/Berichten.dart';
import 'package:Argo/src/ui/tabs/Bronnen.dart';
import 'package:Argo/src/ui/tabs/Cijfers.dart';
import 'package:Argo/src/ui/tabs/Huiswerk.dart';
import 'package:Argo/src/ui/tabs/Info.dart';
import 'package:Argo/src/ui/tabs/Instellingen.dart';
import 'package:Argo/src/ui/tabs/Leermiddelen.dart';
import 'package:Argo/src/ui/tabs/MijnGegevens.dart';
import 'package:Argo/src/ui/tabs/Opdrachten.dart';
import 'package:Argo/src/ui/tabs/Studiewijzer.dart';
import 'package:Argo/src/ui/tabs/Thuis.dart';

import 'package:Argo/src/utils/hive/adapters.dart';

class Tabs {
  Account account;
  List<Map> children;
  Tabs(this.account) {
    children = [
      {
        "page": Thuis(),
        "name": Text("Vandaag"),
        "icon": Icons.home_outlined,
        "color": Colors.orange,
      },
      {
        "page": Agenda(),
        "name": Text("Agenda"),
        "icon": Icons.event_outlined,
        "color": Colors.blue,
      },
      if (account.has("Afspraken", "Read"))
        {
          "page": Huiswerk(),
          "name": Text("Huiswerk"),
          "icon": Icons.assignment_outlined,
          "color": Colors.green[600],
        },
      if (account.has("Absenties", "Read"))
        {
          "name": Text("Afwezigheid"),
          "page": Afwezigheid(),
          "icon": Icons.check_circle_outlined,
          "color": Colors.redAccent,
        },
      if (account.has("Cijfers", "Read"))
        {
          "name": Text("Cijfers"),
          "icon": Icons.looks_6_outlined,
          "page": Cijfers(),
          "color": Colors.cyan[800],
        },
      if (account.has("Berichten", "Read"))
        {
          "name": Text("Berichten"),
          "icon": Icons.email_outlined,
          "page": Berichten(),
          "color": Colors.purple,
        },
      {
        "divider": true,
      },
      if (account.has("Studiewijzers", "Read"))
        {
          "name": Text("Studiewijzers"),
          "icon": Icons.school_outlined,
          "page": Studiewijzers(),
          // "overridePop": true,
          "color": Colors.amber,
        },
      {
        "name": Text("Opdrachten"),
        "icon": Icons.assignment_late_outlined,
        "page": Opdrachten(),
        "color": Colors.grey,
      },
      if (account.has("DigitaalLesmateriaal", "Read"))
        {
          "name": Text("Leermiddelen"),
          "icon": Icons.language_outlined,
          "page": Leermiddelen(),
          "color": Colors.cyan,
        },
      if (account.has("Bronnen", "Read"))
        {
          "name": Text("Bronnen"),
          "icon": Icons.folder_outlined,
          "page": Bronnen(),
          "overridePop": true,
          "color": Colors.indigo[200],
        },
      {
        "divider": true,
      },
      if (account.has("Profiel", "Read"))
        {
          "name": Text("Mijn Gegevens"),
          "icon": Icons.person_outlined,
          "page": MijnGegevens(),
          "color": Colors.pink[200],
        },
      {
        "name": Text("Instellingen"),
        "icon": Icons.settings_outlined,
        "page": Instellingen(),
        "color": Colors.blue[200],
      },
      {
        "name": Text("Over deze app"),
        "icon": Icons.info_outlined,
        "page": Info(),
        "color": Colors.lime[700],
      }
    ];
  }
}
