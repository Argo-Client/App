// Dankjewel Sjoerd, ben er blij mee
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class MagisterAuth {
  final String authURL = "https://accounts.magister.net/connect/authorize";
  final String tokenURL = "https://accounts.magister.net/connect/token";
  String codeVerifier;
  String codeChallenge;
  String nonce;
  String state;
  String code;
  Box tokensBox = Hive.box("magisterTokens");
  MagisterTokenSet tokenSet;
  MagisterAuth() {
    this.nonce = this.generateRandomBase64(32);
    this.state = this.generateRandomString(16);
    this.codeVerifier = generateRandomString(50);
    this.codeChallenge = base64Url.encode(SHA256Digest().process(Uint8List.fromList(this.codeVerifier.codeUnits))).replaceAll('=', '');
  }

  Future<void> checkThenLogin(Function cb) async {
    print("Logging in");
    if (isLoggedIn()) {
      print("Is al ingelogd");
      cb();
    } else {
      print("Open Popup");
      await this.fullLogin(() => checkThenLogin(cb));
    }
  }

  bool isLoggedIn() {
    return tokensBox.containsKey("accessToken");
  }

  String generateRandomString(length) {
    var r = Random.secure();
    var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(50, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String generateRandomBase64(length) {
    var text = "";
    var possible = "abcdef0123456789";
    for (var i = 0; i < length; i++) {
      Random random = new Random();
      text += possible[random.nextInt(possible.length)];
    }
    return text;
  }

  String getURL() {
    return "https://accounts.magister.net/connect/authorize?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256"; // &acr_values=tenant:$tenant&prompt=select_account
  }

  Future<MagisterTokenSet> getTokenSet() async {
    List<int> bodyBytes = utf8.encode("code=$code&redirect_uri=m6loapp://oauth2redirect/&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=$codeVerifier");

    Response response = await post(
      tokenURL,
      headers: {
        "X-API-Client-ID": "EF15",
        "Content-Type": "application/x-www-form-urlencoded",
        "Host": "accounts.magister.net",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Origin": "https://accounts.magister.net",
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 13_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
      },
      body: bodyBytes,
      encoding: Encoding.getByName("utf-8"),
    );

    Map<String, dynamic> parsed = json.decode(response.body);
    var tokenSet = MagisterTokenSet.fromJson(parsed);
    tokensBox.put("accessToken", tokenSet.accessToken);
    tokensBox.put("refreshToken", tokenSet.refreshToken);
    return tokenSet;
  }

  Future<void> fullLogin(Function callback) async {
    String authURL = this.getURL();
    if (await canLaunch(authURL)) {
      await launch(authURL, forceWebView: false, forceSafariVC: false);
      StreamSubscription _sub;
      _sub = getLinksStream().listen((String link) async {
        code = link.split("code=")[1].split("&")[0];
        tokenSet = await this.getTokenSet();
        _sub.cancel();
        callback();
      }, onError: (err) {
        _sub.cancel();
        throw Exception("Stream error ofzo idk");
      });
    } else {
      throw Exception("Invalid auth url");
    }
  }
}

class MagisterTokenSet {
  final String accessToken;
  final String idToken;
  final String refreshToken;
  // final DateTime expiresAt;
  final List<String> scope;

  MagisterTokenSet({
    this.accessToken,
    this.idToken,
    this.refreshToken,
    // this.expiresAt,
    this.scope,
  });

  MagisterTokenSet.fromJson(Map<String, dynamic> json)
      : accessToken = json['access_token'].toString(),
        idToken = json['id_token'].toString(),
        refreshToken = json['refresh_token'].toString(),
        // expiresAt = DateTime.fromMillisecondsSinceEpoch((json["expires_at"] as int) * 1000),
        scope = json['scope'].toString().split(" ");
}
