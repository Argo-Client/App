import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Magister {
  Box tokens = Hive.box("magisterTokens");
  Box userdata = Hive.box("userdata");
  Box data = Hive.box("magisterData");

  dynamic getFromMagister(String link) async {
    final response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + tokens.get("accessToken")});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Magister Wil niet: " + response.statusCode.toString() + link);
      print(response.body);
    }
  }

  void refresh() async {
    profileInfo();
    var id = await getId();
    accountInfo(id);
    // schoolInfo(id);
  }

  Future profileInfo() async {
    var parsed = (await getFromMagister("account"))["Persoon"];
    data.put("id1", parsed["Id"]);
    data.put("officialFullName", parsed["OfficieleVoornamen"] + " " + (parsed["OfficieleTussenvoegsel"] ?? "") + parsed["OfficieleAchternaam"]);
    data.put("fullName", parsed["Roepnaam"] + " " + (parsed["Tussenvoegsel"] ?? "") + parsed["Achternaam"]);
    data.put("name", parsed["Roepnaam"]);
    data.put("initials", parsed["Voorletters"]);
    data.put("birthdate", parsed["Geboortedatum"]);
  }

  Future getId() async {
    var id = (await getFromMagister("sessions/current"))["links"]["account"]["href"].toString().replaceAll(RegExp("\/.*\/"), "");
    data.put("id2", id);
    return id;
  }

  Future accountInfo(id) async {
    var parsed = await getFromMagister('accounts/$id');
    data.put("username", parsed["naam"]);
    data.put("email", parsed["emailadres"]);
  }

  Future schoolInfo(id) async {
    var parsed = await getFromMagister("aanmeldingen/$id");
    data.put("klas", parsed["groep"]["code"]);
    data.put("mentor", '${parsed["persoonlijkeMentor"]["voorletters"]} ${parsed["persoonlijkeMentor"]["achternaam"]}');
    data.put("profiel", parsed["profielen"][0]["omschrijving"]);
  }
}
