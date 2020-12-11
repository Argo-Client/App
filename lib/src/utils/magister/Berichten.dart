import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Argo/src/utils/hive/adapters.dart';

class Berichten extends MagisterApi {
  MagisterApi api;
  Berichten(this.api) : super(api.account);
  DateFormat formatDate = DateFormat("yyyy-MM-dd");
  Future refresh() async {
    return await api.wait([getBerichten()]);
  }

  Future getBerichten() async {
    Map body = (await api.dio.get("api/berichten/postvakin/berichten?top=30")).data;
    account.berichten = body["items"].map((ber) => Bericht(ber)).toList().cast<Bericht>();
  }

  Future<Bericht> getBerichtFrom(Bericht bericht) async {
    Bericht ber = Bericht((await api.dio.get("api/berichten/berichten/${bericht.id}")).data);
    bericht.inhoud = ber.inhoud;
    bericht.ontvangers = ber.ontvangers;
    bericht.cc = ber.cc;
    if (!ber.read) {
      markAsRead(bericht);
    }
    account.save();
    return bericht;
  }

  Future<void> markAsRead(Bericht bericht) async {
    await api.dio.patch("api/berichten/berichten", data: {
      "berichten": [
        {
          "berichtId": bericht.id,
          "operations": [
            {"op": "replace", "path": "/IsGelezen", "value": true}
          ]
        }
      ]
    });

    bericht.read = true;
  }

  Future<List<Bron>> bijlagen(Bericht ber) async {
    List raw = (await api.dio.get("api/berichten/berichten/${ber.id}/bijlagen")).data["items"];
    ber.bijlagen = raw.map((bij) => Bron(bij)).toList().cast<Bron>();
    account.save();
    return ber.bijlagen;
  }
}
