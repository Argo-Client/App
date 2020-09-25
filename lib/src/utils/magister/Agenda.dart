import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'dart:convert';
import 'package:Magistex/src/utils/hiveObjects.dart';
import 'package:http/http.dart' as http;

class Agenda extends MagisterApi {
  Account account;
  Agenda(this.account) : super(account);
  Future refresh() async {
    return await runList([getLessen(account.id)]);
  }

  Future getLessen(id) async {
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));
    DateTime lastSunday = lastMonday.add(Duration(days: 6));
    Completer c = Completer();
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    account.lessons = [[], [], [], [], [], [], []];
    getFromMagister('/personen/$id/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}').then((res) {
      Map body = json.decode(res.body);
      body["Items"].forEach((les) {
        if (les["DuurtHeleDag"]) return;
        DateTime end = DateTime.parse(les["Einde"]).toLocal();
        account.lessons[end.weekday - 1].add(lesFrom(les));
      });
      c.complete(true);
    }).catchError((e) {
      print(e);
      c.completeError(e);
    });
    return c.future;
  }

  Future addAfspraak(Map les) async {
    Map postLes = {
      "Id": 0,
      "Start": les["start"].toUtc().toIso8601String(),
      "Einde": les["eind"].toUtc().add(Duration(hours: 2)).toIso8601String(),
      "DuurtHeleDag": les["heledag"] ?? false,
      "Omschrijving": les["title"],
      "Lokatie": les["locatie"],
      "Inhoud": les["inhoud"],
      "Status": 2,
      "InfoType": 6,
      "Type": 1,
    };
    return await postToMagister(
      "personen/${account.id}/afspraken",
      postLes,
    );
  }

  Future deleteLes(Map les) async {
    http.Response deleted = await http.delete("https://${account.tenant}/api/personen/${account.id}/afspraken/${les["id"]}", headers: {"Authorization": "Bearer " + account.accessToken});
    if (deleted.statusCode == 204) {
      return true;
    }
    return deleted.body;
  }

  Map lesFrom(var les) {
    DateTime start = DateTime.parse(les["Start"]).toLocal();
    DateTime end = DateTime.parse(les["Einde"]).toLocal();
    int startHour = les['LesuurVan'];
    int endHour = les["LesuurTotMet"];

    DateFormat formatHour = DateFormat("HH:mm");
    DateFormat formatDatum = DateFormat("EEEE dd MMMM");
    var docent;
    int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
    var hour = (startHour == endHour ? startHour.toString() : '$startHour - $endHour');
    if (les["Docenten"] != null && !les["Docenten"].isEmpty) {
      docent = les["Docenten"][0]["Naam"];
    }
    return {
      "start": minFromMidnight ?? "",
      "duration": end.difference(start).inMinutes ?? "",
      "hour": hour == "null" ? "" : hour,
      "startTime": formatHour.format(start),
      "endTime": formatHour.format(end),
      "description": les["Inhoud"] ?? "",
      "title": les["Omschrijving"] ?? "",
      "location": les["Lokatie"],
      "date": formatDatum.format(end),
      "vak": les["Vakken"].isEmpty ? les["Omschrijving"] : les["Vakken"][0]["Naam"],
      "docent": docent,
      "uitval": les["Status"] == 5,
      "information": (!["", null].contains(les["Lokatie"]) ? les["Lokatie"] + " • " : "") + formatHour.format(start) + " - " + formatHour.format(end) + (les["Inhoud"] != null ? " • " + les["Inhoud"].replaceAll(RegExp("<[^>]*>"), "") : ""),
      "editable": les["Type"] == 1,
      "id": les["Id"]
    };
  }
}
