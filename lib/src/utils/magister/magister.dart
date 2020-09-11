part of main;

class Magister {
  dynamic getFromMagister(String link) async {
    final response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken, "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.106 Safari/537.36"});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Magister Wil niet: " + response.statusCode.toString() + link);
      print(response.body);
    }
  }

  Future refresh() async {
    await getExpiry();
    account.id = await profileInfo();
    await Future.wait([
      refreshProfileInfo(),
      refreshAgenda(),
    ]);
    account.save();
    return;
  }

  Future refreshToken() async {
    final response = await http.post("https://accounts.magister.net/connect/token", body: {
      "refresh_token": account.refreshToken,
      "client_id": "M6LOAPP",
      "grant_type": "refresh_token",
    });
    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);
      account.saveTokens(parsed);
      print("refreshed token");
      await getExpiry();
      return;
    } else {
      print("Magister Wil niet token verversen: " + response.statusCode.toString());
      print(response.body);
    }
  }

  Future runWithToken() async {
    if (DateTime.now().millisecondsSinceEpoch > account.expiry) {
      print("Token expired, refreshing");
      await refreshToken();
      return;
    }
    return;
  }

  Future refreshProfileInfo() async {
    await runWithToken();
    await Future.wait([
      getUsername(account.id),
      schoolInfo(account.id),
      personInfo(account.id),
      getAdress(account.id),
    ]);
    account.save();
    return;
  }

  Future refreshAgenda() async {
    await runWithToken();
    await Future.wait([
      getLessen(account.id),
    ]);
    account.save();
    return;
  }

  Future getExpiry() async {
    var parsed = await getFromMagister("sessions/current");
    int expiry = DateTime.parse(parsed["expiresOn"]).millisecondsSinceEpoch;
    account.expiry = expiry;
  }

  Future profileInfo() async {
    var parsed = (await getFromMagister("account"))["Persoon"];
    account.id = parsed["Id"];
    account.officialFullName = parsed["OfficieleVoornamen"] + " " + (parsed["OfficieleTussenvoegsel"] != null ? parsed["OfficieleTussenvoegsel"] + " " : "") + parsed["OfficieleAchternaam"];
    account.fullName = parsed["Roepnaam"] + " " + (parsed["Tussenvoegsel"] ?? "") + parsed["Achternaam"];
    account.name = parsed["Roepnaam"];
    account.initials = parsed["Voorletters"];
    account.birthdate = parsed["Geboortedatum"];
    return parsed["Id"];
  }

  Future getUsername(id) async {
    var parsed = await getFromMagister('leerlingen/$id');
    account.username = parsed["stamnummer"].toString();
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

  Future getLessen(id) async {
    var parsed = (await getFromMagister('/personen/$id/afspraken?van=2020-09-11&tot=2020-09-11'))["Items"];
    account.lessons = [];
    parsed.forEach((les) {
      account.lessons.add({
        "start": les["Start"],
        "eind": les["Eind"],
        "beschrijving": les["Inhoud"],
        "naam": les["Omschrijving"],
        "locatie": les["Lokatie"],
      });
    });

    account.save();
  }
}
