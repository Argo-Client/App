import 'dart:async';

import 'package:intl/intl.dart';
import 'magister.dart';
import 'package:argo/src/utils/hive/adapters.dart';

class QueryResponse {
  String initials;
  String firstname;
  String tussenvoegsel;
  String lastname;
  String klas;

  int id;

  String get naam {
    return "${firstname ?? initials} ${tussenvoegsel != null ? "$tussenvoegsel " : ""}$lastname";
  }

  String toString() => naam;

  Contact toContact() {
    var contact = Contact();
    contact.id = id;
    contact.naam = naam;
    return contact;
  }

  QueryResponse(Map json) {
    initials = json["voorletters"];
    firstname = json["roepnaam"];
    tussenvoegsel = json["tussenvoegsel"];
    lastname = json["achternaam"];
    klas = json["klas"];

    id = json["id"];
  }
}

class Berichten extends MagisterApi {
  Map<String, Iterable<QueryResponse>> queryCache = {};

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

  Future<Iterable<QueryResponse>> search(String query) async {
    if (queryCache[query] != null) {
      return queryCache[query];
    }
    if (query.length < 2) {
      return [];
    }

    List raw = (await api.dio.get(
      "/api/contacten/personen",
      queryParameters: {
        "q": query,
      },
    ))
        .data["items"];

    queryCache[query] = raw.map((e) => QueryResponse(e)).toList();
    return queryCache[query];
  }

  Future<void> send({List<Contact> to, String subject, String content, bool priority = false}) async {
    await api.dio.post("/api/berichten/berichten", data: {
      "ontvangers": to.map((e) => {"id": e.id, "type": "persoon"}).toList(),
      "onderwerp": subject,
      "inhoud": content,
      "heeftPrioriteit": priority
    });
  }
}
