import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'dart:convert';
import 'package:argo/src/utils/hive/adapters.dart';

class Agenda extends MagisterApi {
  MagisterApi api;
  Agenda(this.api) : super(api.account);
  Future refresh() async {
    return await api.wait([getLessen()]);
  }

  Future<List<List<Les>>> getLessen([DateTime lastM]) async {
    DateTime now = DateTime.now();
    DateTime lastMonday = lastM ??
        now.subtract(
          Duration(
            days: now.weekday - 1,
          ),
        );
    DateTime lastSunday = lastMonday.add(
      Duration(
        days: 6,
      ),
    );
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    Map body = (await api.dio.get('api/personen/${account.id}/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}')).data;
    String weekslug = formatDate.format(lastMonday);
    account.lessons[weekslug] = <List<Les>>[[], [], [], [], [], [], []];
    body["Items"].forEach((les) {
      DateTime end = DateTime.parse(les["Start"]).toLocal();
      account.lessons[weekslug][end.weekday - 1].add(Les(les));
    });
    if (account.isInBox) account.save();
    return account.lessons[weekslug];
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
        data: json.encode({"Id": les.id, "Afgerond": !les.huiswerkAf, "Aantekening": les.aantekening}),
      );
      if (res.statusCode == 200) {
        return true;
      }
      return res.data;
    } catch (e) {
      return (e);
    }
  }

  Future<List<Bron>> getBijlagen(Les les) async {
    Map raw = (await api.dio.get("api/personen/${account.id}/afspraken/${les.id}")).data;
    Les newLes = Les(raw);
    les.bijlagen = newLes.bijlagen;
    account.save();
    return newLes.bijlagen;
  }
}
