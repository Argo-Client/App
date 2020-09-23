import 'package:Magistex/src/utils/hiveObjects.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'dart:developer';
import 'dart:convert';
import 'ProfileInfo.dart';
import 'Agenda.dart';
import 'Cijfers.dart';
import 'Afwezigheid.dart';
import 'Berichten.dart';

class MagisterApi {
  Account account;
  MagisterApi(this.account);
  dynamic getFromMagister(String link, [bool dontParse, bool resOnly]) async {
    http.Response response = await http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken});
    if (response.statusCode == 200) {
      if (resOnly == true) {
        return response;
      }
      if (dontParse == true) {
        return response.body;
      }
      return json.decode(response.body);
    } else {
      if (response.body.contains("Expired")) {
        print("Magister heeft je genaaid zonder het te zeggen");
        await refreshToken();
        return await getFromMagister(link, dontParse, resOnly);
      }
      print("Magister Wil niet: " + response.statusCode.toString() + link);
      print(response.body);
    }
  }

  dynamic postToMagister(String link, Map postBody) async {
    try {
      http.Response res = await http.post('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken, "Content-Type": "application/json"}, body: json.encode(postBody));
      if (res.statusCode != 201) {
        if (res.body.contains("Expired")) {
          print("Magister heeft je genaaid zonder het te zeggen");
          await refreshToken();
          return await postToMagister(link, postBody);
        }
        print("Magister Wil geen post: " + res.statusCode.toString() + link);
        print(res.body);
      }
      return res.statusCode == 201;
    } catch (e) {
      print("error geketst:");
      print(e);
      return e;
    }
  }

  Future runWithToken() async {
    if (DateTime.now().add(Duration(minutes: 10)).millisecondsSinceEpoch > account.expiry) {
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
      if (response.body == '{"error":"invalid_grant"}') {
        print("$account is uitgelogd!");
        dynamic tokenSet = await MagisterAuth().fullLogin();
        account.saveTokens(tokenSet);
        account.save();
        await getExpiry();
        return;
      }
      print("Magister Wil niet token verversen: " + response.statusCode.toString());
      print(response.body);
    }
  }

  Future getExpiry() async {
    var parsed = await getFromMagister("sessions/current");
    int expiry = DateTime.parse(parsed["expiresOn"]).millisecondsSinceEpoch;
    account.expiry = expiry;
  }
}

class Magister {
  Account account;
  ProfileInfo profileInfo;
  Agenda agenda;
  Cijfers cijfers;
  MagisterApi api;
  Afwezigheid afwezigheid;
  Berichten berichten;
  Magister(Account acc) {
    this.account = acc;
    api = MagisterApi(acc);
    profileInfo = ProfileInfo(acc);
    agenda = Agenda(acc);
    cijfers = Cijfers(acc);
    afwezigheid = Afwezigheid(acc);
    berichten = Berichten(acc);
  }
  Future refresh() async {
    await api.runWithToken();
    await api.getExpiry();
    account.id = await profileInfo.profileInfo();
    await api.runList([
      agenda.refresh(),
      profileInfo.refresh(),
      afwezigheid.refresh(),
      berichten.refresh(),
      // cijfers.getCijfers(),
      downloadProfilePicture(),
    ]);
    log('Refreshed $account');
    return;
  }

  Future downloadProfilePicture() async {
    http.Response img = await MagisterApi(account).getFromMagister("leerlingen/${account.id}/foto", true, true);
    String image = base64Encode(img.bodyBytes);
    account.profilePicture = image;
  }
}
