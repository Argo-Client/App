import 'dart:async';
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
    Map body = (await api.dio.get("api/account")).data["Persoon"];
    account.id = body["Id"];
    account.officialFullName = body["OfficieleVoornamen"] + " " + (body["OfficieleTussenvoegsel"] != null ? body["OfficieleTussenvoegsel"] + " " : "") + body["OfficieleAchternaam"];
    account.fullName = body["Roepnaam"] + " " + (body["Tussenvoegsel"] != null ? body["Tussenvoegsel"] + " " : "") + body["Achternaam"];
    account.name = body["Roepnaam"];
    account.initials = body["Voorletters"];
    account.birthdate = body["Geboortedatum"];
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
