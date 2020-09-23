import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class Agenda extends MagisterApi {
  Account account;
  Agenda(this.account) : super(account);
  Future refresh() async {
    await runList([getLessen(account.id)]);
    account.save();
    return;
  }

  Future getLessen(id) async {
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));
    DateTime lastSunday = lastMonday.add(Duration(days: 6));

    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    var parsed = (await getFromMagister('/personen/$id/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}'))["Items"];
    account.lessons = [
      [],
      [],
      [],
      [],
      [],
      [],
      [],
    ];
    parsed.forEach((les) {
      if (les["DuurtHeleDag"]) return;
      DateTime end = DateTime.parse(les["Einde"]).toLocal();
      account.lessons[end.weekday - 1].add(lesFrom(les));
    });
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
    print(postLes);
    return await postToMagister(
      "personen/${account.id}/afspraken",
      postLes,
    );
  }

  Map lesFrom(var les) {
    DateTime start = DateTime.parse(les["Start"]).toLocal();
    DateTime end = DateTime.parse(les["Einde"]).toLocal();
    int startHour = les['LesuurVan'];
    int endHour = les["LesuurTotMet"];

    DateFormat formatHour = DateFormat("HH:mm");
    DateFormat formatDatum = DateFormat("EEEE dd MMMM");
    int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
    var hour = (startHour == endHour ? startHour.toString() : '$startHour - $endHour');

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
      "docent": ![[], null].contains(["Docenten"]) ? "" : les["Docenten"][0]["Naam"],
      "uitval": les["Status"] == 5,
      "information": (!["", null].contains(les["Lokatie"]) ? les["Lokatie"] + " • " : "") + formatHour.format(start) + " - " + formatHour.format(end) + (les["Inhoud"] != null ? " • " + les["Inhoud"].replaceAll(RegExp("<[^>]*>"), "") : "")
      // "bewerkt": "kerst",
    };
  }
}
