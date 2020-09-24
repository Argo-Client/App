import 'dart:async';

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
    Completer c = Completer();
    http.get('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken}).then((response) async {
      if (response.statusCode == 200) {
        c.complete(response);
      } else {
        if (response.body.contains("Expired")) {
          print("Magister heeft je genaaid zonder het te zeggen");
          await refreshToken();
          return await getFromMagister(link, dontParse, resOnly);
        }
        print("Magister Wil niet: " + response.statusCode.toString() + link);
        print(response.body);
        c.completeError(response.body);
      }
    }).catchError((e) {
      print(e);
      c.completeError(e);
    });
    return c.future;
  }

  dynamic postToMagister(String link, Map postBody) async {
    Completer c = Completer();
    http.post('https://pantarijn.magister.net/api/$link', headers: {"Authorization": "Bearer " + account.accessToken, "Content-Type": "application/json"}, body: json.encode(postBody)).then((res) async {
      if (res.statusCode != 201) {
        if (res.body.contains("Expired")) {
          print("Magister heeft je genaaid zonder het te zeggen");
          await refreshToken();
          c.complete(await postToMagister(link, postBody));
        }
        print("Magister Wil geen post: " + res.statusCode.toString() + link);
        print(res.body);
        c.completeError(res.body);
        return;
      }
      c.complete(res.statusCode == 201);
    });
    return c.future;
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
    List values = await Future.wait(list);
    if (account.isInBox) {
      account.save();
    }
    return values;
  }

  Future refreshToken() async {
    Completer c = Completer();
    http.post("https://accounts.magister.net/connect/token", body: {
      "refresh_token": account.refreshToken,
      "client_id": "M6LOAPP",
      "grant_type": "refresh_token",
    }).then((http.Response response) async {
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);
        account.saveTokens(parsed);
        print("Refreshed token");
        await getExpiry();
        c.complete();
      } else {
        if (response.body == '{"error":"invalid_grant"}') {
          print("$account is uitgelogd!");
          dynamic tokenSet = await MagisterAuth().fullLogin();
          account.saveTokens(tokenSet);
          account.save();
          await getExpiry();
          c.complete();
        }
        print("Magister Wil niet token verversen: " + response.statusCode.toString());
        print(response.body);
        c.completeError(response.body);
      }
    }).catchError((e) {
      print(e);
      c.completeError(e);
    });
    return c.future;
  }

  Future getExpiry() async {
    getFromMagister("sessions/current").then((res) {
      Map body = json.decode(res.body);
      int expiry = DateTime.parse(body["expiresOn"]).millisecondsSinceEpoch;
      account.expiry = expiry;
      account.save();
    }).catchError((e) {
      log("Error expiry geketst:");
      print(e);
    });
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
    await profileInfo.profileInfo();
    return await api.runList([
      agenda.refresh(),
      profileInfo.refresh(),
      afwezigheid.refresh(),
      berichten.refresh(),
      // cijfers.getCijfers(),
      downloadProfilePicture(),
    ]);
  }

  Future downloadProfilePicture() async {
    http.Response img = await MagisterApi(account).getFromMagister("leerlingen/${account.id}/foto", true, true);
    String image = base64Encode(img.bodyBytes);
    account.profilePicture = image;
  }
}
