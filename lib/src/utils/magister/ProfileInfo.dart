import 'dart:async';
import 'package:argo/src/utils/hive/adapters.dart';

import 'magister.dart';

class ProfileInfo extends MagisterApi {
  MagisterApi api;
  ProfileInfo(this.api) : super(api.account);
  Future refresh() async {
    return await api.wait([
      schoolInfo(),
      personInfo(),
      getAdress(),
      profileInfo(),
    ]);
  }

  Future getTenant() async {
    Map body = (await api.dio.get("https://magister.net/.well-known/host-meta.json?rel=magister-api")).data;
    account.tenant = Uri.parse(body["links"].first["href"]).host;
  }

  Future profileInfo() async {
    Map body = (await api.dio.get("api/account")).data;
    account.privileges = body["Groep"][0]["Privileges"].map((priv) => Privilege(priv)).toList().cast<Privilege>();
    Map pers = body["Persoon"];
    account.id = pers["Id"];
    account.officialFullName = pers["OfficieleVoornamen"] + " " + (pers["OfficieleTussenvoegsels"] != null ? pers["OfficieleTussenvoegsels"] + " " : "") + pers["OfficieleAchternaam"];
    account.fullName = pers["Roepnaam"] + " " + (pers["Tussenvoegsel"] != null ? pers["Tussenvoegsel"] + " " : "") + pers["Achternaam"];
    account.name = pers["Roepnaam"];
    account.initials = pers["Voorletters"];
    account.birthdate = pers["Geboortedatum"];
  }

  Future schoolInfo() async {
    if (!account.has("Aanmeldingen", "Read")) {
      return print("Skipped Aanmeldingen");
    }

    Map body = (await api.dio.get('api/leerlingen/${account.id}/aanmeldingen')).data["items"][0];
    account.klasCode = body["groep"]["code"];
    account.klas = body["studie"]["code"];
  }

  Future personInfo() async {
    if (!account.has("Profiel", "Read")) {
      return print("Skipped Profiel");
    }

    Map body = (await api.dio.get('api/personen/${account.id}/profiel')).data;
    account.email = body["EmailAdres"].toString();
    account.phone = body["Mobiel"].toString();
  }

  Future getAdress() async {
    Map body = (await api.dio.get('api/personen/${account.id}/adresprofiel')).data;

    account.address = '${body["Straatnaam"]} ${body["Huisnummer"]}${body["Toevoeging"] ?? ""}\n${body["Postcode"]}, ${body["Woonplaats"]}';
  }
}
