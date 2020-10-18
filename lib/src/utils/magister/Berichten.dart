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

  Future<Bericht> getBerichtFromId(id) async {
    Map body = (await api.dio.get("api/berichten/berichten/$id")).data;
    return Bericht(body);
  }
}
