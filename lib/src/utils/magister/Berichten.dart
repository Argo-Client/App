import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Argo/src/utils/hiveObjects.dart';
import 'dart:convert';

class Berichten extends MagisterApi {
  Account account;
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  DateFormat formatDatum = DateFormat("EEEE dd MMMM");
  Berichten(this.account) : super(account);
  Future refresh() async {
    return await runList([getBerichten()]);
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
    getFromMagister("berichten/postvakin/berichten?top=30").then((res) {
      account.berichten = json.decode(res.body)["items"].map((ber) => parseBericht(ber)).toList();
    });
  }

  Future<Map> getBerichtFromId(id) async {
    var res = await getFromMagister("berichten/berichten/$id");
    Map body = json.decode(res.body);
    Map ber = {
      "inhoud": body["inhoud"],
      "ontvangers": body["ontvangers"].take(10).map((ont) => ont["weergavenaam"]).join(" "),
    };
    // ber.addAll(parseBericht(body));
    return ber;
  }
}
