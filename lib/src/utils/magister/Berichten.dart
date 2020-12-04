import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:Argo/src/utils/hive/adapters.dart';
import 'package:dio/dio.dart';

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

  Future<Bericht> getBerichtFromId(int id) async {
    Bericht bericht = Bericht((await api.dio.get("api/berichten/berichten/$id")).data);
    if (!bericht.read) {
      markAsRead(id);
      bericht.read = true;
    }
    return bericht;
  }

  Future<void> markAsRead(int id) async {
    Response res = await api.dio.patch("api/berichten/berichten", data: {
      "berichten": [
        {
          "berichtId": id,
          "operations": [
            {"op": "replace", "path": "/IsGelezen", "value": true}
          ]
        }
      ]
    });
    print(res.statusCode);
  }
}
