import 'magister.dart';
import 'package:Magistex/src/utils/hiveObjects.dart';

class ProfileInfo extends MagisterApi {
  Account account;
  ProfileInfo(this.account) : super(account);
  Future refresh() async {
    await runList([
      getUsername(account.id),
      schoolInfo(account.id),
      personInfo(account.id),
      getAdress(account.id),
    ]);
    account.save();
    return;
  }

  Future getUsername(id) async {
    var parsed = await getFromMagister('leerlingen/$id');
    account.username = parsed["stamnummer"].toString();
  }

  Future profileInfo() async {
    var parsed = (await getFromMagister("account"))["Persoon"];
    account.id = parsed["Id"];
    account.officialFullName = parsed["OfficieleVoornamen"] + " " + (parsed["OfficieleTussenvoegsel"] != null ? parsed["OfficieleTussenvoegsel"] + " " : "") + parsed["OfficieleAchternaam"];
    account.fullName = parsed["Roepnaam"] + " " + (parsed["Tussenvoegsel"] != null ? parsed["Tussenvoegsel"] + " " : "") + parsed["Achternaam"];
    account.name = parsed["Roepnaam"];
    account.initials = parsed["Voorletters"];
    account.birthdate = parsed["Geboortedatum"];
    return parsed["Id"];
  }

  Future schoolInfo(id) async {
    var parsed = (await getFromMagister('/leerlingen/$id/aanmeldingen'))["items"][0];
    account.klasCode = parsed["groep"]["code"];
    account.klas = parsed["studie"]["code"];
    account.mentor = '${parsed["persoonlijkeMentor"]["voorletters"]} ${parsed["persoonlijkeMentor"]["achternaam"]}';
    account.profiel = parsed["profielen"][0]["code"];
  }

  Future personInfo(id) async {
    var parsed = (await getFromMagister('/personen/$id/profiel'));
    account.email = parsed["EmailAdres"].toString();
    account.phone = parsed["Mobiel"].toString();
  }

  Future getAdress(id) async {
    var parsed = (await getFromMagister('/personen/$id/adressen'))["items"][0];
    account.address = '${parsed["straat"]} ${parsed["huisnummer"]}\n${parsed["postcode"]}, ${parsed["plaats"]}';
  }
}
