import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:futuristic/futuristic.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

class LoginView extends StatefulWidget {
  final MagisterLogin log;
  final String title;
  LoginView(this.log, this.title);
  @override
  _LoginView createState() => _LoginView(log, title);
}

class _LoginView extends State<LoginView> {
  MagisterLogin magisterLogin;
  String redirectUrl;
  WebViewController controller;
  String title;
  _LoginView(this.magisterLogin, this.title);
  Widget build(BuildContext context) {
    CookieManager().clearCookies();
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Inloggen"),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == "herlaad") {
                String url = await controller.currentUrl();
                controller.loadUrl(url);
              } else {
                launch(magisterLogin.url);
                StreamSubscription _sub;
                _sub = getLinksStream().listen((String link) async {
                  _sub.cancel();
                  await magisterLogin.getTokenSet(link, context);
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "herlaad",
                child: Text("Herlaad"),
              ),
              PopupMenuItem(
                value: "browser",
                child: Text("Open in browser"),
              )
            ],
          )
        ],
      ),
      body: redirectUrl == null
          ? WebView(
              initialUrl: magisterLogin.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebResourceError: (error) async {
                if (error.errorCode == -2) return; // Internet
                controller.loadUrl(magisterLogin.url);
              },
              navigationDelegate: (req) {
                if (req.url.contains("#code")) {
                  setState(() => redirectUrl = req.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onWebViewCreated: (controller) {
                this.controller = controller;
              },
            )
          : Center(
              child: Futuristic(
                autoStart: true,
                futureBuilder: () async => magisterLogin.getTokenSet(redirectUrl, context),
                onData: (value) => Navigator.pop(context),
                busyBuilder: (context) {
                  return Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        Text("Token Exchange"),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class MagisterLogin {
  // Dit is niet meer Sjoerd zijn code, maar ik heb er wel zeker gebruik van gemaakt om te weten hoe dit werkt.
  // https://github.com/Argo-Magister/App/blob/07c73024e9ed131d746626610910b53d616b2a5e/lib/src/utils/magister/login.dart
  String codeVerifier;
  String url;
  String title;
  Function callback;
  Map preFill;
  void launch(context, Function cb, {Map preFill, String title}) {
    this.preFill = preFill;
    this.callback = cb;
    this.title = title;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginView(this, title),
      ),
    );
  }

  MagisterLogin() {
    this.url = createURL();
  }

  String generateRandomString() {
    var r = Random.secure();
    var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return Iterable.generate(50, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String generateRandomBase64(length) {
    var r = Random.secure();
    var chars = 'abcdef0123456789';
    return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)]).join();
  }

  String createURL() {
    String nonce = generateRandomBase64(32);
    this.codeVerifier = generateRandomString();
    String state = generateRandomString();
    String codeChallenge = base64Url.encode(SHA256Digest().process(Uint8List.fromList(this.codeVerifier.codeUnits))).replaceAll('=', '');
    String str = "https://accounts.magister.net/connect/authorize?client_id=M6LOAPP&redirect_uri=m6loapp%3A%2F%2Foauth2redirect%2F&scope=openid%20profile%20offline_access%20magister.mobile%20magister.ecs&response_type=code%20id_token&state=$state&nonce=$nonce&code_challenge=$codeChallenge&code_challenge_method=S256";
    if (preFill != null) {
      str += "&acr_values=tenant:${preFill["tenant"]}&prompt=select_account&login_hint=${preFill['username']}";
    }
    return str;
  }

  Future<Map> getTokenSet(String url, BuildContext context) async {
    String code = url.replaceFirst(RegExp("^m6.*#code="), "").split("&")[0];
    Response res = await post(
      "https://accounts.magister.net/connect/token",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: utf8.encode("code=$code&redirect_uri=m6loapp://oauth2redirect/&client_id=M6LOAPP&grant_type=authorization_code&code_verifier=$codeVerifier"),
    );
    callback(jsonDecode(res.body), context);
    return jsonDecode(res.body);
  }
}
