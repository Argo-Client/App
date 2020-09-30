import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';

class Berichten extends MagisterApi {
  MagisterApi api;
  Berichten(this.api) : super(api.account);
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  Future refresh() async {
    return await api.wait([getBerichten()]);
  }

  Map<String, dynamic> parseBericht(ber) {
    return {
      "dag": formatDatum.format(DateTime.parse(ber["verzondenOp"])),
      "id": ber["id"],
      "prioriteit": ber["heeftPrioriteit"],
      "bijlagen": ber["heeftBijlagen"],
      "onderwerp": ber["onderwerp"],
      "afzender": ber["afzender"]["naam"],
    };
  }

  Future getBerichten() async {
    Map body = (await api.dio.get("api/berichten/postvakin/berichten?top=30")).data;
    account.berichten = body["items"].map((ber) => parseBericht(ber)).toList();
  }

  Future<Map> getBerichtFromId(id) async {
    Map body = (await api.dio.get("api/berichten/berichten/$id")).data;
    Map ber = {
      "inhoud": body["inhoud"],
      "ontvangers": body["ontvangers"].take(10).map((ont) => ont["weergavenaam"]).join(" "),
    };
    // ber.addAll(parseBericht(body));
    return ber;
  }
}
