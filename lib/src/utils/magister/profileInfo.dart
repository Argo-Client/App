import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class ProfileInfo {
  Box tokens = Hive.box("magisterTokens");
  Box userdata = Hive.box("userdata");
  Box data = Hive.box("magisterData");
  ProfileInfo() {}
  void refresh() {
    http.get("https://pantarijn.magister.net/api/account?noCache=0", headers: {"Authorization": "Bearer " + tokens.get("accessToken")}).then((response) {
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body)["Persoon"];

        data.put("name", parsed["Roepnaam"]);
        data.put("lastname", parsed["Achternaam"]);
        data.put("insertion", parsed["Tussenvoegsel"]);
        data.put("initials", parsed["Voorletters"]);
        data.put("birthdate", parsed["Geboortedatum"]);
        data.put("officialName", parsed["OfficieleVoornamen"]);
        data.put("officialLastname", parsed["OfficieleAchternaam"]);
        data.put("officialInsertion", parsed["OfficieleTussenvoegsel"]);
      } else {
        print("Magister Wil niet: " + response.statusCode.toString());
        print(response.body);
        // throw Exception("Magister wil niet");
      }
    });
  }
}
