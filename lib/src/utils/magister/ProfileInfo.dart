import 'dart:async';
import 'package:Argo/src/utils/hive/adapters.dart';

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
    Map body = (await api.dio.get('api/leerlingen/${account.id}/aanmeldingen')).data["items"][0];
    account.klasCode = body["groep"]["code"];
    account.klas = body["studie"]["code"];
    account.profiel = body["profielen"][0]["code"];
  }

  Future personInfo() async {
    Map body = (await api.dio.get('api/personen/${account.id}/profiel')).data;
    account.email = body["EmailAdres"].toString();
    account.phone = body["Mobiel"].toString();
  }

  Future getAdress() async {
    Map body = (await api.dio.get('api/personen/${account.id}/adressen')).data["items"][0];
    account.address = '${body["straat"]} ${body["huisnummer"]}\n${body["postcode"]}, ${body["plaats"]}';
  }
}
