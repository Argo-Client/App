import 'package:Magistex/src/utils/hiveObjects.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'ProfileInfo.dart';
import 'Agenda.dart';
import 'Cijfers.dart';

class MagisterApi {
  Account account;
  MagisterApi(this.account);
  dynamic getFromMagister(String link) async {
    final response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Magister Wil niet: " + response.statusCode.toString() + link);
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

  Future getExpiry() async {
    var parsed = await getFromMagister("sessions/current");
    int expiry = DateTime.parse(parsed["expiresOn"]).subtract(Duration(minutes: 10)).millisecondsSinceEpoch;
    account.expiry = expiry;
  }
}

class Magister {
  Account account;
  ProfileInfo profileInfo;
  Agenda agenda;
  Cijfers cijfers;
  MagisterApi api;
  Magister(Account acc) {
    this.account = acc;
    profileInfo = ProfileInfo(acc);
    agenda = Agenda(acc);
    cijfers = Cijfers(acc);
    api = MagisterApi(acc);
  }
  Future refresh() async {
    await api.runWithToken();
    await api.getExpiry();
    account.id = await profileInfo.profileInfo();
    await api.runList([
      agenda.refresh(),
      profileInfo.refresh(),
      // cijfers.getCijfers(),
      downloadProfilePicture(),
    ]);
    log('Refreshed $account');
    return;
  }

  Future downloadProfilePicture() async {
    http.Response img = (await http.get('https://pantarijn.magister.net/api/leerlingen/${account.id}/foto', headers: {"Authorization": "Bearer " + account.accessToken}));
    String image = base64Encode(img.bodyBytes);
    account.profilePicture = image;
  }
}
