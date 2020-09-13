import 'package:Magistex/src/utils/hiveObjects.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:intl/intl.dart';

class Magister {
  Account account;
  Magister(this.account);
  dynamic getFromMagister(String link) async {
    final response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken});
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
    await runList([
      refreshProfileInfo(),
      refreshAgenda(),
      downloadProfilePicture(),
    ]);
    log('Refreshed $account');
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

  Future runList(List<Future> list) async {
    await runWithToken();
    await Future.wait(list);
    if (account.isInBox) {
      account.save();
    }
    return;
  }

  Future refreshProfileInfo() async {
    await runList([
      getUsername(account.id),
      schoolInfo(account.id),
      personInfo(account.id),
      getAdress(account.id),
    ]);
    return;
  }

  Future refreshAgenda() async {
    await runList([getLessen(account.id)]);
    return;
  }

  Future downloadProfilePicture() async {
    http.Response img = (await http.get('https://pantarijn.magister.net/api/leerlingen/${account.id}/foto', headers: {"Authorization": "Bearer " + account.accessToken}));
    String image = base64Encode(img.bodyBytes);
    account.profilePicture = image;
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
    DateTime now = DateTime.now();
    DateTime lastMonday = now.subtract(Duration(days: now.weekday - 1));
    DateTime lastSunday = lastMonday.add(Duration(days: 6));
    DateFormat formatDate = DateFormat("yyyy-MM-dd");
    DateFormat formatHour = DateFormat("HH:mm");
    var parsed = (await getFromMagister('/personen/$id/afspraken?van=${formatDate.format(lastMonday)}&tot=${formatDate.format(lastSunday)}'))["Items"];
    account.lessons = [[], [], [], [], [], [], []];
    parsed.forEach((les) {
      if (les["DuurtHeleDag"]) return;
      DateTime start = DateTime.parse(les["Start"]).toLocal();
      DateTime end = DateTime.parse(les["Einde"]).toLocal();
      int startHour = les['LesuurVan'];
      int endHour = les["LesuurTotMet"];
      int minFromMidnight = start.difference(DateTime(end.year, end.month, end.day)).inMinutes;
      if (minFromMidnight <= 480) return;
      account.lessons[end.weekday - 1].add({
        "start": minFromMidnight ?? "",
        "duration": end.difference(start).inMinutes ?? "",
        "hour": (startHour == endHour ? startHour.toString() : '$startHour - $endHour') ?? "",
        "startTime": formatHour.format(start),
        "endTime": formatHour.format(end),
        "description": les["Inhoud"] != null ? " • " + les["Inhoud"] : "",
        "title": les["Omschrijving"] ?? "",
        "location": les["Lokatie"] != null ? les["Lokatie"] + " • " : "",
      });
    });
  }
}
