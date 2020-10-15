import 'magister.dart';

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${this.substring(1)}";
}

class Cijfers extends MagisterApi {
  MagisterApi api;
  Cijfers(this.api) : super(api.account);
  Future refresh() async {
    // account.cijfers = [];
    await cijferJaren();
    await api.wait([recentCijfers(), cijferPerioden(), cijfers()]);
  }

  Future recentCijfers() async {
    // List recent = (await api.dio.get("api/personen/${account.id}/cijfers/laatste?top=50&skip=0")).data["items"];
  }

  Future cijferJaren() async {
    List perioden = (await api.dio.get("api/leerlingen/${account.id}/aanmeldingen?begin=1970-01-01")).data["items"];
    account.cijfers = perioden
        .map((per) => {
              "id": per["id"],
              "eind": per["einde"],
              "leerjaar": per["studie"]["code"],
              "cijfers": [],
              "perioden": [],
            })
        .toList();
  }

  Future cijferPerioden() async {
    for (var i = 0; i < account.cijfers.length; i++) {
      List perioden = (await api.dio.get("/api/personen/${account.id}/aanmeldingen/${account.cijfers[i]["id"]}/cijfers/cijferperiodenvooraanmelding")).data["Items"];
      account.cijfers[i]["perioden"] = perioden
          .map((per) => {
                "abbr": per["Naam"],
                "naam": per["Omschrijving"],
                "id": per["Id"],
              })
          .toList();
      (account.cijfers[i]["perioden"] as List<Map>).sort((a, b) => a["id"].compareTo(b["id"]));
    }
  }

  Future cijfers() async {
    for (var i = 0; i < account.cijfers.length; i++) {
      List cijfers = (await api.dio.get("api/personen/${account.id}/aanmeldingen/${account.cijfers[i]["id"]}/cijfers/cijferoverzichtvooraanmelding?actievePerioden=true&alleenBerekendeKolommen=false&alleenPTAKolommen=false&peildatum=${account.cijfers[i]["eind"]}")).data["Items"];
      account.cijfers[i]["cijfers"] = cijfers
          .map((cijfer) => {
                "ingevoerd": DateTime.parse(cijfer["DatumIngevoerd"] ?? "1970-01-01T00:00:00.0000000Z"),
                "cijfer": cijfer["CijferStr"],
                "vak": {
                  "naam": (cijfer["Vak"]["Omschrijving"] as String).capitalize,
                  "id": cijfer["Vak"]["Id"],
                },
                "periode": cijfer["CijferPeriode"] == null
                    ? {}
                    : {
                        "id": cijfer["CijferPeriode"]["Id"],
                        "naam": cijfer["CijferPeriode"]["Naam"],
                      },
              })
          .toList();
      (account.cijfers[i]["cijfers"] as List<Map>).sort((a, b) => a["ingevoerd"].millisecondsSinceEpoch.compareTo(b["ingevoerd"].millisecondsSinceEpoch));
      account.cijfers[i]["cijfers"] = account.cijfers[i]["cijfers"].reversed.toList();
    }
  }
}
