import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class Agenda extends MagisterApi {
  Account account;
  Agenda(this.account) : super(account);
  Future refresh() async {
    await runList([getLessen(account.id)]);
    return;
  }

  Future getLessen(id) async {
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));
    DateTime lastSunday = lastMonday.add(Duration(days: 6));
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    DateFormat formatHour = DateFormat("HH:mm");
    DateFormat formatDatum = DateFormat("EEEE dd MM");
    var parsed = (await getFromMagister('/personen/$id/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}'))["Items"];
    account.lessons = [[], [], [], [], [], [], []];
    parsed.forEach((les) {
      if (les["DuurtHeleDag"]) return;
      DateTime start = DateTime.parse(les["Start"]).toLocal();
      DateTime end = DateTime.parse(les["Einde"]).toLocal();
      int startHour = les['LesuurVan'];
      int endHour = les["LesuurTotMet"];
      int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
      if (minFromMidnight <= 480) return;
      account.lessons[end.weekday - 1].add({
        "start": minFromMidnight ?? "",
        "duration": end.difference(start).inMinutes ?? "",
        "hour": (startHour == endHour ? startHour.toString() : '$startHour - $endHour') ?? "",
        "startTime": formatHour.format(start),
        "endTime": formatHour.format(end),
        "description": les["Inhoud"] ?? "",
        "title": les["Omschrijving"] ?? "",
        "location": les["Lokatie"] != null ? les["Lokatie"] + " • " : "",
        "date": formatDatum.format(end),
        "vak": les["Vakken"].isEmpty ? les["Omschrijving"] : les["Vakken"][0]["Naam"],
        "docent": "Je moeder",
        "bewerkt": "kerst",
      });
    });
  }
}
