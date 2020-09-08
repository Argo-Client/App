import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class Magister {
  Box tokens = Hive.box("magisterTokens");
  Box userdata = Hive.box("userdata");
  Box data = Hive.box("magisterData");

  dynamic getFromMagister(String link) async {
    final response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + tokens.get("accessToken"), "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Safari/537.36"});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      if (response.body.endsWith("Expired")) {
        print("Refresh token pls");
        return;
      }
      print("Magister Wil niet: " + response.statusCode.toString() + link);
      print(response.body);
    }
  }

  Future<Box> refresh() async {
    var userId = await profileInfo();
    await Future.wait([
      getUsername(userId),
      schoolInfo(userId),
      personInfo(userId),
      getAdress(userId),
    ]);

    return data;
  }

  Future profileInfo() async {
    var parsed = (await getFromMagister("account"))["Persoon"];
    data.put("id", parsed["Id"]);
    data.put("officialFullName", parsed["OfficieleVoornamen"] + " " + ((parsed["OfficieleTussenvoegsel"].toString() + " ") ?? "") + parsed["OfficieleAchternaam"]);
    data.put("fullName", parsed["Roepnaam"] + " " + (parsed["Tussenvoegsel"] ?? "") + parsed["Achternaam"]);
    data.put("name", parsed["Roepnaam"]);
    data.put("initials", parsed["Voorletters"]);
    data.put("birthdate", parsed["Geboortedatum"]);
    return parsed["Id"];
  }

  Future getUsername(id) async {
    var parsed = await getFromMagister('leerlingen/$id');
    data.put("username", parsed["stamnummer"].toString());
  }

  Future schoolInfo(id) async {
    var parsed = (await getFromMagister('/leerlingen/$id/aanmeldingen'))["items"][0];
    data.put("klasCode", parsed["groep"]["code"]);
    data.put("klas", parsed["studie"]["code"]);
    data.put("mentor", '${parsed["persoonlijkeMentor"]["voorletters"]} ${parsed["persoonlijkeMentor"]["achternaam"]}');
    data.put("profiel", parsed["profielen"][0]["code"]);
  }

  Future personInfo(id) async {
    var parsed = (await getFromMagister('/personen/$id/profiel'));
    data.put("email", parsed["EmailAdres"].toString());
    data.put("phone", parsed["Mobiel"].toString());
  }

  Future getAdress(id) async {
    var parsed = (await getFromMagister('/personen/$id/adressen'))["items"][0];
    data.put("address", '${parsed["straat"]} ${parsed["huisnummer"]}\n${parsed["postcode"]}, ${parsed["plaats"]}');
  }
}
