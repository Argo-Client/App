import 'dart:async';
import 'dart:convert';
import 'magister.dart';
import 'package:Argo/src/utils/hiveObjects.dart';

class ProfileInfo extends MagisterApi {
  Account account;
  ProfileInfo(this.account) : super(account);
  Future refresh() async {
    await runWithToken();
    return await runList([
      schoolInfo(),
      personInfo(),
      getAdress(),
      profileInfo(),
    ]);
  }

  Future profileInfo() async {
    var res = await getFromMagister("account");
    Map body = json.decode(res.body)["Persoon"];
    account.id = body["Id"];
    account.officialFullName = body["OfficieleVoornamen"] + " " + (body["OfficieleTussenvoegsel"] != null ? body["OfficieleTussenvoegsel"] + " " : "") + body["OfficieleAchternaam"];
    account.fullName = body["Roepnaam"] + " " + (body["Tussenvoegsel"] != null ? body["Tussenvoegsel"] + " " : "") + body["Achternaam"];
    account.name = body["Roepnaam"];
    account.initials = body["Voorletters"];
    account.birthdate = body["Geboortedatum"];
  }

  Future schoolInfo() async {
    var res = await getFromMagister('/leerlingen/${account.id}/aanmeldingen');
    Map body = json.decode(res.body)["items"][0];
    account.klasCode = body["groep"]["code"];
    account.klas = body["studie"]["code"];
    account.mentor = '${body["persoonlijkeMentor"]["voorletters"]} ${body["persoonlijkeMentor"]["achternaam"]}';
    account.profiel = body["profielen"][0]["code"];
  }

  Future personInfo() async {
    var res = await getFromMagister('/personen/${account.id}/profiel');
    Map body = json.decode(res.body);
    account.email = body["EmailAdres"].toString();
    account.phone = body["Mobiel"].toString();
  }

  Future getAdress() async {
    var res = await getFromMagister('/personen/${account.id}/adressen');
    Map body = json.decode(res.body)["items"][0];
    account.address = '${body["straat"]} ${body["huisnummer"]}\n${body["postcode"]}, ${body["plaats"]}';
  }
}
