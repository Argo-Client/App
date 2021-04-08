import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:argo/main.dart';
import 'package:argo/src/utils/hive/adapters.dart';
import 'package:dio/dio.dart' as dio;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:futuristic/futuristic.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:math';
import 'package:http/http.dart';
import 'package:pointycastle/export.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';

import 'package:argo/src/ui/components/Card.dart';
import 'package:argo/src/ui/components/Utils.dart';
import 'package:argo/src/ui/components/ListTileBorder.dart';

Box<Account> accounts = Hive.box("accounts");

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

  Account account;
  _LoginView(this.magisterLogin, this.title);

  Widget errorBuilder(context, dynamic error, retry) => Column(
        children: [
          SelectableText(
            error.toString(),
            maxLines: 10,
          ),
          if (error.runtimeType == dio.DioError && error.response != null)
            SelectableText(
              error.toString(),
              maxLines: 10,
            ),
          ElevatedButton(
            child: Text("Retry"),
            onPressed: retry,
          ),
          Text("Argo is in beta, mocht er hier iets anders staan dan 'Geen Internet' stuur even een screenshot. Dan kunnen we het zo snel mogelijk oplossen"),
        ],
      );

  Widget build(BuildContext context) {
    CookieManager().clearCookies();
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Inloggen"),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if (value == "herlaad") {
                if (redirectUrl == null) {
                  String url = await controller.currentUrl();
                  controller.loadUrl(url);
                }
              } else {
                launch(magisterLogin.url);
                StreamSubscription _sub;
                _sub = getLinksStream().listen((String link) async {
                  _sub.cancel();
                  setState(() => redirectUrl = link);
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
          : Container(
              height: MediaQuery.of(context).size.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - kToolbarHeight,
              child: Futuristic(
                autoStart: true,
                errorBuilder: errorBuilder,
                futureBuilder: () async => magisterLogin.getTokenSet(redirectUrl, context),
                busyBuilder: (c) => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Inlog Verifiëren"),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
                dataBuilder: (c, Map tokenSet) => Futuristic(
                  autoStart: true,
                  errorBuilder: errorBuilder,
                  futureBuilder: () async {
                    account = Account(tokenSet);
                    if (account.tenant == null) {
                      await account.magister.profileInfo.getTenant();
                    }
                    if (account.id == 0) return account.magister.profileInfo.profileInfo();
                    return Future.value(true);
                  },
                  busyBuilder: (c) => Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Account Id Ophalen"),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                  onData: (_) {
                    if (accounts.values.any((acc) => acc.id == account.id && account != acc)) {
                      Navigator.pop(context);
                      MagisterLogin().launch(
                        context,
                        magisterLogin.callback,
                        title: magisterLogin.title,
                        preFill: magisterLogin.preFill,
                      );
                    }
                  },
                  dataBuilder: (context, _) {
                    if (accounts.values.any((acc) => acc.id == account.id && account != acc)) {
                      Fluttertoast.showToast(
                        msg: "$account is al ingelogd!",
                      );
                      return Center(
                        child: Text("$account is al ingelogd!"),
                      );
                    }
                    return RefreshAccountView(account, context, magisterLogin.callback);
                  },
                ),
              ),
            ),
    );
  }
}

class MagisterLoader extends StatelessWidget {
  final String name;
  final Future Function() future;
  final ValueNotifier<int> count;
  final ValueNotifier<List<List>> errors;
  MagisterLoader({this.name, this.future, this.count, this.errors});
  @override
  Widget build(c) => MaterialCard(
        child: ListTileBorder(
          border: Border(
            top: greyBorderSide(),
          ),
          leading: Container(
            padding: EdgeInsets.only(top: 4.5),
            child: Text(
              name,
              style: TextStyle(fontSize: 17.5),
            ),
          ),
          trailing: Futuristic(
            autoStart: true,
            futureBuilder: future,
            busyBuilder: (context) => CircularProgressIndicator(),
            onData: (_) {
              count.value++;
            },
            onError: (error, retry) {
              errors.value.add([error, retry]);
              // ignore: invalid_use_of_protected_member,invalid_use_of_visible_for_testing_member
              errors.notifyListeners();
            },
            errorBuilder: (context, error, retry) => Icon(
              Icons.clear,
              color: Colors.red,
            ),
            dataBuilder: (c, d) => Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ),
      );
}

class RefreshAccountView extends StatelessWidget {
  final ValueNotifier<int> totalLoaded = ValueNotifier(0);

  final ValueNotifier<List<List>> errors = ValueNotifier([]);
  static List<Widget> loaders;
  final Account account;
  final BuildContext context;
  final Function callback;
  RefreshAccountView(this.account, this.context, this.callback) {
    loaders = [
      if (account.has("Afspraken", "Read"))
        MagisterLoader(
          name: "Agenda",
          future: account.magister.agenda.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Absenties", "Read"))
        MagisterLoader(
          name: "Afwezigheid",
          future: account.magister.afwezigheid.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Berichten", "Read"))
        MagisterLoader(
          name: "Berichten",
          future: account.magister.berichten.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Bronnen", "Read"))
        MagisterLoader(
          name: "Bronnen",
          future: account.magister.bronnen.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Cijfers", "Read"))
        MagisterLoader(
          name: "Cijfers",
          future: account.magister.cijfers.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("DigitaalLesmateriaal", "Read"))
        MagisterLoader(
          name: "Leermiddelen",
          future: account.magister.leermiddelen.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Studiewijzers", "Read"))
        MagisterLoader(
          name: "Studiewijzers",
          future: account.magister.studiewijzers.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      if (account.has("Profiel", "Read"))
        MagisterLoader(
          name: "Profiel Info",
          future: account.magister.profileInfo.refresh,
          count: totalLoaded,
          errors: errors,
        ),
      MagisterLoader(
        name: "Profiel Foto",
        future: account.magister.downloadProfilePicture,
        count: totalLoaded,
        errors: errors,
      ),
    ];
    totalLoaded.addListener(() {
      if (totalLoaded.value == loaders.length) {
        if (!account.isInBox) accounts.add(account);
        Navigator.pop(context);
        callback(account, context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ValueListenableBuilder(
          valueListenable: totalLoaded,
          builder: (c, loaded, _) => LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color.fromARGB(
                100,
                255,
                255,
                255,
              ),
            ),
            backgroundColor: userdata.get("primaryColor"),
            value: loaded / loaders.length,
          ),
        ),
        for (MagisterLoader loader in loaders) loader,
        ValueListenableBuilder(
          valueListenable: errors,
          builder: (context, _, _a) {
            return errors.value.isEmpty
                ? Container()
                : Column(
                    children: [
                      SelectableText(
                        errors.value.first.first.toString(),
                        maxLines: 10,
                      ),
                      if (errors.value.first.first.runtimeType == dio.DioError && errors.value.first.first.response != null)
                        SelectableText(
                          errors.value.first.first.response.data.toString(),
                          maxLines: 10,
                        ),
                      ElevatedButton(
                        child: Text("Retry"),
                        onPressed: () {
                          errors.value.forEach(
                            (error) => error.last(),
                          );
                          errors.value = [];
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          totalLoaded.value = loaders.length;
                        },
                        child: Text("Boeie gewoon door"),
                      ),
                      Text("Argo is in beta, mocht er hier iets anders staan dan 'Geen Internet' stuur even een screenshot. Dan kunnen we het zo snel mogelijk oplossen"),
                    ],
                  );
          },
        ),
      ],
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
    // callback(jsonDecode(res.body), context);
    return jsonDecode(res.body);
  }
}
