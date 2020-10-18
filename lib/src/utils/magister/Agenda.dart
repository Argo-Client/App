import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'dart:convert';
import 'package:Argo/src/utils/hive/adapters.dart';

class Agenda extends MagisterApi {
  MagisterApi api;
  Agenda(this.api) : super(api.account);
  Future refresh() async {
    return await api.wait([getLessen()]);
  }

  Future getLessen([DateTime lastM]) async {
    DateTime now = DateTime.now();
    DateTime lastMonday = lastM ?? now.subtract(Duration(days: now.weekday - 1));
    DateTime lastSunday = lastMonday.add(Duration(days: 6));
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    Map body = (await api.dio.get('api/personen/${account.id}/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}')).data;
    String weekslug = formatDate.format(lastMonday);
    account.lessons[weekslug] = <List<Les>>[[], [], [], [], [], [], []];
    body["Items"].forEach((les) {
      if (les["DuurtHeleDag"]) return;
      DateTime end = DateTime.parse(les["Einde"]).toLocal();
      account.lessons[weekslug][end.weekday - 1].add(Les(les));
    });
    return;
  }

  Future addAfspraak(Map les) async {
    Map postLes = {
      "Id": 0,
      "Start": les["start"].toUtc().toIso8601String(),
      "Einde": les["eind"].toUtc().toIso8601String(),
      "DuurtHeleDag": les["heledag"] ?? false,
      "Omschrijving": les["title"],
      "Lokatie": les["locatie"],
      "Inhoud": les["inhoud"],
      "Status": 2,
      "InfoType": les["inhoud"] != null ? 6 : 0,
      "Type": 1,
    };
    return await api.dio.post("api/personen/${account.id}/afspraken", data: postLes);
  }

  Future deleteLes(Les les) async {
    try {
      var deleted = await api.dio.delete("api/personen/${account.id}/afspraken/${les.id}");
      if (deleted.statusCode == 204) {
        return true;
      }
      return deleted.data;
    } catch (e) {
      return (e);
    }
  }

  Future toggleHuiswerk(Les les) async {
    try {
      var res = await api.dio.put(
        "api/personen/${account.id}/afspraken/${les.id}",
        data: json.encode({"Id": les.id, "Afgerond": !les.huiswerkAf}),
      );
      if (res.statusCode == 200) {
        return true;
      }
      return res.data;
    } catch (e) {
      return (e);
    }
  }

  // Map lesFrom(var les) {
  //   DateTime start = DateTime.parse(les["Start"]).toLocal();
  //   DateTime end = DateTime.parse(les["Einde"]).toLocal();
  //   int startHour = les['LesuurVan'];
  //   int endHour = les["LesuurTotMet"];

  //   DateFormat formatHour = DateFormat("HH:mm");
  //   DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  //   var docent;
  //   int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
  //   var hour = (startHour == endHour ? startHour.toString() : '$startHour - $endHour');
  //   if (les["Docenten"] != null && !les["Docenten"].isEmpty) {
  //     docent = les["Docenten"][0]["Naam"];
  //   }
  //   return {
  //     "start": minFromMidnight ?? "",
  //     "duration": end.difference(start).inMinutes ?? "",
  //     "hour": hour == "null" ? "" : hour,
  //     "startTime": formatHour.format(start),
  //     "endTime": formatHour.format(end),
  //     "description": les["Inhoud"] ?? "",
  //     "title": les["Omschrijving"] ?? "",
  //     "location": les["Lokatie"],
  //     "date": formatDatum.format(end),
  //     "vak": les["Vakken"].isEmpty ? les["Omschrijving"] : les["Vakken"][0]["Naam"],
  //     "docent": docent,
  //     "huiswerk": les["Inhoud"],
  //     "huiswerkAf": les["Afgerond"],
  //     "uitval": les["Status"] == 5,
  //     "information": (!["", null].contains(les["Lokatie"]) ? les["Lokatie"] + " • " : "") + formatHour.format(start) + " - " + formatHour.format(end) + (les["Inhoud"] != null ? " • " + les["Inhoud"].replaceAll(RegExp("<[^>]*>"), "") : ""),
  //     "editable": les["Type"] == 1,
  //     "id": les["Id"]
  //   };
  // }
}
